//
//  LottaHttpInterceptorProvider.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 02/10/2023.
//

import Foundation
import Apollo
import ApolloAPI

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    private var loginSession: LoginSession?
    
    init(loginSession: LoginSession?, store: ApolloStore) {
        self.loginSession = loginSession
        super.init(shouldInvalidateClientOnDeinit: true, store: store)
    }
    
    override func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] where Operation : GraphQLOperation {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(AuthorizationInterceptor(loginSession: self.loginSession), at: 0)
        interceptors.insert(RefreshTokenInterceptor(loginSession: self.loginSession), at: 5)
        return interceptors
    }
}
