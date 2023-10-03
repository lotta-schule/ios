//
//  CurrentSession.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//
import SwiftUI
import JWTDecode
import Apollo
import KeychainSwift

class LoginSession {
    enum RenewError: Error {
        case invalidToken
        case missingToken
    }
    
    var accessToken: JWT?
    var _refreshToken: JWT?
    
    var refreshToken: JWT? {
        get {
            _refreshToken
        }
        set {
            if let stringValue = newValue?.string, let tid = newValue?.claim(name: "tid").integer {
                keychain.set(stringValue, forKey: "\(tid)--refresh-token")
            }
            _refreshToken = newValue
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
    
    func renew(additionalHeaders: [String:String] = [:], completion: @escaping (Result<TokenPair, RenewError>) -> (Void)) -> Void {
        guard let refreshToken = refreshToken else {
            completion(.failure(.missingToken))
            return
        }
        
        let url = LOTTA_API_HTTP_URL.appending(path: "/auth/token/refresh")
            .appending(queryItems: [URLQueryItem(name: "token", value: refreshToken.string)])
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let tokens = try? JSONDecoder().decode(TokenPair.Json.self, from: data) else {
                completion(.failure(.invalidToken))
                return
            }
            
            let tokenPair = tokens.asPair()
            guard let accessToken = tokenPair.accessToken, let refreshToken = tokenPair.refreshToken else {
                completion(.failure(.invalidToken))
                return
            }
            
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            
            completion(.success(tokenPair))
        }.resume()

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
