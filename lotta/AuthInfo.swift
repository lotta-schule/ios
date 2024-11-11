//
//  AuthInfo.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//
import Sentry
import Apollo
import SwiftUI
import JWTDecode

class AuthInfo {
    enum RenewError: Error {
        case invalidToken
        case missingToken
        case connectionError
    }
    
    var accessToken: JWT?
    var refreshToken: JWT?
    
    var needsRenew: Bool {
        get {
            if accessToken == nil {
                return true
            }
            guard let refreshToken = refreshToken else {
                return false
            }
            return refreshToken.expired
        }
    }
    
    init(accessToken: JWT? = nil, refreshToken: JWT? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    var isLoggedIn: Bool {
        if let accessToken = self.accessToken {
            return accessToken.expired == false
        }
        if let refreshToken = self.refreshToken {
            return refreshToken.expired == false
        }
        return false
    }
    
    func renew(completion: @escaping (Result<TokenPair, RenewError>) -> (Void)) -> Void {
        let crumb = Breadcrumb(level: .info, category: "AuthInfo#renew")
        crumb.message = "Renewing access token"
        crumb.data = ["refreshToken": refreshToken?.string ?? "(nil)"]
        SentrySDK.addBreadcrumb(crumb)
        
        guard let refreshToken = refreshToken else {
            SentrySDK.capture(message: "AuthInfo#renew: missing refreshToken")
            completion(.failure(.missingToken))
            return
        }
        guard let tid = refreshToken.claim(name: "tid").integer else {
            SentrySDK.capture(message: "AuthInfo#renew: Token not valid because it doesn't contain a tid")
            completion(.failure(.invalidToken))
            return
        }
        
        let url = LOTTA_API_HTTP_URL.appending(path: "/auth/token/refresh")
            .appending(queryItems: [URLQueryItem(name: "token", value: refreshToken.string)])
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.setValue("id:\(tid)", forHTTPHeaderField: "tenant")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                SentrySDK.capture(error: error)
                completion(.failure(.connectionError))
                return
            }
            guard let data = data, let tokens = try? JSONDecoder().decode(TokenPair.Json.self, from: data) else {
                SentrySDK.capture(message: "Renewal failed: invalid response data (\(data?.base64EncodedString() ?? "(nil)")")
                completion(.failure(.invalidToken))
                return
            }
            
            let tokenPair = tokens.asPair()
            guard let accessToken = tokenPair.accessToken, let refreshToken = tokenPair.refreshToken else {
                SentrySDK.capture(message: "Invalid token from tokenPair: \(tokenPair)")
                completion(.failure(.invalidToken))
                return
            }
            
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            
            self.saveToKeychain()
            
            completion(.success(tokenPair))
        }.resume()
    }
        
    func renewAsync() async throws -> TokenPair {
        return try await withCheckedThrowingContinuation { continuation in
            return self.renew() { result in
                switch result {
                case .success(let tokenPair):
                    continuation.resume(returning: tokenPair)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    func saveToKeychain() -> Void {
        guard let refreshToken = refreshToken else {
            SentrySDK.capture(message: "Could not save refreshToken to keychain because refreshToken is (nil).")
            return
        }
        guard let tenantId = refreshToken.claim(name: "tid").integer else {
            SentrySDK.capture(message: "Could not save refreshToken to keychain because it does not contain a uid claim.")
            return
        }
        guard let userId = refreshToken.subject else {
            SentrySDK.capture(message: "Could not save refreshToken to keychain because it does not contain a tenantId (subject) claim.")
            return
        }
        keychain.set(refreshToken.string, forKey: "\(tenantId)-\(userId)--refresh-token")
    }
    
    struct TokenPair {
        var accessToken: JWT?
        var refreshToken: JWT?
        
        struct Json: Codable {
            var accessToken: String?
            var refreshToken: String?
            
            func asPair() -> TokenPair {
                let accessToken: JWT? = self.accessToken != nil ? try? decode(jwt: self.accessToken!) : nil
                let refreshToken: JWT? = self.refreshToken != nil ? try? decode(jwt: self.refreshToken!) : nil
                
                return TokenPair(
                    accessToken: accessToken,
                    refreshToken: refreshToken
                )
            }
        }
    }
}
