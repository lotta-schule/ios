//
//  RefreshTokenInterceptor.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 02/10/2023.
//

import Foundation
import Apollo
import ApolloAPI
import JWTDecode

class RefreshTokenInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString
    
    private var loginSession: LoginSession?
    
    init(loginSession: LoginSession?) {
        self.loginSession = loginSession
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        if let loginSession = loginSession,
           let fields = response?.httpResponse.allHeaderFields as? [String: String],
           let url = response?.httpResponse.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            if let refreshCookie = cookies.first(where: { $0.name == "SignInRefreshToken" }),
               let refreshToken = try? decode(jwt: refreshCookie.value) {
                loginSession.refreshToken = refreshToken
            }
        }
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
