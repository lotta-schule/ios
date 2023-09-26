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

let BASE_HOST = "core.staging.lotta.schule"
let HTTP_URL = URL(string: "https://\(BASE_HOST)/api")!
let WEBSOCKET_URL = URL(string: "wss://\(BASE_HOST)/api/graphql-socket/websocket")!

class CoreApi: ObservableObject {
    let apollo: ApolloClient
    
    let tenant: Tenant?
    
    init(userToken: String?, tenant: Tenant?) {
        self.tenant = tenant
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        
        /// A web socket transport to use for subscriptions
        let webSocketTransport: WebSocketTransport? = if let token = userToken, let tid = tenant?.id {
            WebSocketTransport(
                websocket: WebSocket(
                    url: WEBSOCKET_URL,
                    protocol: .graphql_transport_ws
                ),
                config: WebSocketTransport.Configuration(
                connectingPayload: [
                    "tid": tid,
                    "token": token
                ]
            ))
        } else {
            nil
        }

        var additionalHeaders: [String:String] = [:]
        if let token = userToken {
            additionalHeaders["Authorization"] = "Bearer \(token)"
        }
        if let slug = tenant?.slug {
            additionalHeaders["Tenant"] = "slug:\(slug)"
        }
        /// An HTTP transport to use for queries and mutations
        let httpTransport = RequestChainNetworkTransport(
            interceptorProvider: DefaultInterceptorProvider(store: store),
            endpointURL: HTTP_URL,
            additionalHeaders: additionalHeaders
        )
        
        /// A split network transport to allow the use of both of the above
        /// transports through a single `NetworkTransport` instance.
        let splitNetworkTransport: SplitNetworkTransport? = if let webSocketTransport = webSocketTransport {
            SplitNetworkTransport(
                uploadingNetworkTransport: httpTransport,
                webSocketNetworkTransport: webSocketTransport
            )
        } else {
            nil
        }
        
        apollo = ApolloClient(networkTransport: splitNetworkTransport ?? httpTransport, store: store)
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
