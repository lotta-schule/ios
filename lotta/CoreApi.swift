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

fileprivate let BASE_HOST = "core.staging.lotta.schule"
fileprivate let HTTP_URL = URL(string: "https://\(BASE_HOST)/api")!
fileprivate let WEBSOCKET_URL = URL(string: "wss://\(BASE_HOST)/api/graphql-socket/websocket")!

fileprivate func getHttpTransport(authToken: String? = nil, tenantSlug slug: String? = nil, store: ApolloStore) -> RequestChainNetworkTransport {
    var additionalHeaders: [String:String] = [:]
    if let token = authToken {
        additionalHeaders["Authorization"] = "Bearer \(token)"
    }
    if let slug = slug {
        additionalHeaders["Tenant"] = "slug:\(slug)"
    }
    /// An HTTP transport to use for queries and mutations
    return RequestChainNetworkTransport(
        interceptorProvider: DefaultInterceptorProvider(store: store),
        endpointURL: HTTP_URL,
        additionalHeaders: additionalHeaders
    )
}

fileprivate func getWSTransport(authToken: String, tenantId tid: String, store: ApolloStore) -> WebSocketTransport {
    return WebSocketTransport(
        websocket: WebSocket(
            url: WEBSOCKET_URL,
            protocol: .graphql_transport_ws
        ),
        config: WebSocketTransport.Configuration(
        connectingPayload: [
            "tid": tid,
            "token": authToken
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
    init(withTenantSlug slug: String, authToken: String? = nil) {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let transport = getHttpTransport(authToken: authToken, tenantSlug: slug, store: store)
        self.apollo = ApolloClient(networkTransport: transport, store: store)
    }
    init(withTenantSlug slug: String, tenantId: String, andAuthToken authToken: String) {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let httpTransport = getHttpTransport(authToken: authToken, tenantSlug: slug, store: store)
        let wsTransport = getWSTransport(authToken: authToken, tenantId: tenantId, store: store)
        
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
