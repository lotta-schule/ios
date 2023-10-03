//
//  CoreApi.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import Foundation
import Apollo
import ApolloAPI
import ApolloWebSocket
import Combine
import LottaCoreAPI
import SwiftData

let LOTTA_API_HOST = "core.staging.lotta.schule"
let LOTTA_API_HTTP_URL = URL(string: "https://\(LOTTA_API_HOST)")!
let LOTTA_API_WEBSOCKET_URL = URL(string: "wss://\(LOTTA_API_HOST)/api/graphql-socket/websocket")!

fileprivate func getHttpTransport(loginSession: LoginSession? = nil, tenantSlug slug: String? = nil, store: ApolloStore) -> RequestChainNetworkTransport {
    var additionalHeaders: [String:String] = [:]
    if let slug = slug {
        additionalHeaders["Tenant"] = "slug:\(slug)"
    }
    /// An HTTP transport to use for queries and mutations
    return RequestChainNetworkTransport(
        interceptorProvider: NetworkInterceptorProvider(loginSession: loginSession, store: store),
        endpointURL: LOTTA_API_HTTP_URL.appending(path: "/api"),
        additionalHeaders: additionalHeaders
    )
}

fileprivate func getWSTransport(loginSession: LoginSession, tenantId tid: String, store: ApolloStore) -> WebSocketTransport {
    return WebSocketTransport(
        websocket: WebSocket(
            url: LOTTA_API_WEBSOCKET_URL,
            protocol: .graphql_transport_ws
        ),
        config: WebSocketTransport.Configuration(
        connectingPayload: [
            "tid": tid,
            "token": loginSession.accessToken?.string
        ]
    ))
}

class CoreApi {
    private(set) var apollo: ApolloClient
    
    init() {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let transport = getHttpTransport(store: store)
        let client  = ApolloClient(networkTransport: transport, store: store)
        
        self.apollo = client
    }
    init(withTenantSlug slug: String, loginSession: LoginSession? = nil) {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let transport = getHttpTransport(loginSession: loginSession, tenantSlug: slug, store: store)
        self.apollo = ApolloClient(networkTransport: transport, store: store)
    }
    init(withTenantSlug slug: String, tenantId: String, andLoginSession loginSession: LoginSession) {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let httpTransport = getHttpTransport(loginSession: loginSession, tenantSlug: slug, store: store)
        let wsTransport = getWSTransport(loginSession: loginSession, tenantId: tenantId, store: store)
        
        let transport =
            SplitNetworkTransport(
                uploadingNetworkTransport: httpTransport,
                webSocketNetworkTransport: wsTransport
            )
        
        self.apollo = ApolloClient(networkTransport: transport, store: store)
    }
}

extension ApolloClient {
    func fetchAsync<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch) async throws -> GraphQLResult<Query.Data> {
    return try await withCheckedThrowingContinuation { continuation in
      fetch(query: query, cachePolicy: cachePolicy) { result in
        switch result {
        case .success(let value):
          continuation.resume(returning: value)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
    func performAsync<Mutation: GraphQLMutation>(mutation: Mutation) async throws -> GraphQLResult<Mutation.Data> {
    return try await withCheckedThrowingContinuation { continuation in
      perform(mutation: mutation) { result in
        switch result {
        case .success(let value):
          continuation.resume(returning: value)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
