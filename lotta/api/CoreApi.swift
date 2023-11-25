//
//  CoreApi.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import Sentry
import Apollo
import Combine
import SwiftData
import ApolloAPI
import Foundation
import ApolloSQLite
import LottaCoreAPI
import KeychainSwift
import ApolloWebSocket

let LOTTA_API_HOST = "core.staging.lotta.schule"
let USE_SECURE_CONNECTION = true
let LOTTA_API_HTTP_URL = URL(string: "\(USE_SECURE_CONNECTION ? "https" : "http")://\(LOTTA_API_HOST)")!
let LOTTA_API_WEBSOCKET_URL = URL(string: "\(USE_SECURE_CONNECTION ? "wss" : "ws")://\(LOTTA_API_HOST)/api/graphql-socket/websocket")!

let KEYCHAIN_PREFIX = String(LOTTA_API_HOST.prefix(5) + LOTTA_API_HOST.suffix(5))
let keychain = KeychainSwift(keyPrefix: KEYCHAIN_PREFIX)

fileprivate func getHttpTransport(loginSession: AuthInfo? = nil, tenantSlug slug: String? = nil, store: ApolloStore) -> RequestChainNetworkTransport {
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

fileprivate func getWSTransport(loginSession: AuthInfo, tenantId tid: String, store: ApolloStore) -> WebSocketTransport {
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
        )
    )
}

var baseCacheDirURL: URL {
    get {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        
        return documentsURL.appending(path: LOTTA_API_HOST.replacing(/:\d{4,5}$/, with: ""))
    }
}

class CoreApi {
    private(set) var apollo: ApolloClient
    
    var cacheUrl: URL?
    
    static func getCacheUrl(tenantId: String) -> URL {
        let sqliteFileURL = baseCacheDirURL.appendingPathComponent("tenant_\(tenantId).sqlite")
        print(sqliteFileURL)
        return sqliteFileURL
    }
    
    init() {
        let store = ApolloStore()
        let transport = getHttpTransport(store: store)
        let client  = ApolloClient(networkTransport: transport, store: store)
        
        self.apollo = client
    }

    init(withTenantSlug slug: String, loginSession: AuthInfo? = nil) {
        let store = ApolloStore()
        let transport = getHttpTransport(loginSession: loginSession, tenantSlug: slug, store: store)
        self.apollo = ApolloClient(networkTransport: transport, store: store)
    }

    init(withTenantSlug slug: String, tenantId: String, andLoginSession loginSession: AuthInfo) {
        cacheUrl = CoreApi.getCacheUrl(tenantId: tenantId)
        
        let sqliteCache = try! SQLiteNormalizedCache(fileURL: cacheUrl!)
        
        let store = ApolloStore(cache: sqliteCache)
        let httpTransport = getHttpTransport(loginSession: loginSession, tenantSlug: slug, store: store)
        let wsTransport = getWSTransport(loginSession: loginSession, tenantId: tenantId, store: store)
        
        let transport =
            SplitNetworkTransport(
                uploadingNetworkTransport: httpTransport,
                webSocketNetworkTransport: wsTransport
            )
        
        self.apollo = ApolloClient(networkTransport: transport, store: store)
    }
    
    func resetCache() -> Void {
        if let url = cacheUrl {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

extension ApolloClient {
    func fetchAsync<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataAndFetch, queue: DispatchQueue = .main) async throws -> Query.Data {
        var didFinish = false
        return try await withCheckedThrowingContinuation({ continuation in
            self.fetch(query: query, cachePolicy: cachePolicy, queue: queue) { [weak self] result in
                if !didFinish {
                    switch result {
                    case .success(let data):
                        let error = data.errors?.first
                        _ = error?.extensions?["code"] as? String
                        if let error = error {
                            didFinish = true
                            continuation.resume(throwing: error)
                        } else if let data = data.data {
                            didFinish = true
                            continuation.resume(returning: data)
                        } else {
                            let errorUn = NSError(domain: "Can't get data at this time", code: 403)
                            didFinish = true
                            continuation.resume(throwing: errorUn)
                        }
                    case .failure(let error):
                        didFinish = true
                        SentrySDK.capture(error: error)
                        continuation.resume(throwing: error)
                    }
                }
          }
        })
      }
  
    func performAsync<Mutation: GraphQLMutation>(mutation: Mutation) async throws -> GraphQLResult<Mutation.Data> {
        return try await withCheckedThrowingContinuation { continuation in
            perform(mutation: mutation) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    SentrySDK.capture(error: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
