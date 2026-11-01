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
    
    private var loginSession: AuthInfo?
    
    init(loginSession: AuthInfo?) {
        self.loginSession = loginSession
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        if let loginSession = loginSession,
           let httpResponse = response?.httpResponse,
           let refreshToken = AuthInfo.refreshToken(fromCookiesOf: httpResponse) {
            loginSession.refreshToken = refreshToken
        }
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
