import Foundation
import Apollo
import ApolloAPI
import JWTDecode

class AuthorizationInterceptor: ApolloInterceptor {
    enum UserError: Error {
        case noUserLoggedIn
    }
    
    public var id: String = UUID().uuidString
    
    private var loginSession: LoginSession?
    
    init(loginSession: LoginSession?) {
        self.loginSession = loginSession
    }
    
    /// Helper function to add the token then move on to the next step
    private func addTokenAndProceed<Operation: GraphQLOperation>(
        _ token: JWT?,
        to request: HTTPRequest<Operation>,
        chain: RequestChain,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        if let token = token?.string {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        if self.loginSession?.accessToken == nil && self.loginSession?.refreshToken == nil {
            chain.proceedAsync(
                request: request,
                response: response,
                interceptor: self,
                completion: completion
            )
            return
        }
        
        // If we've gotten here, there is a token!
        guard (self.loginSession?.refreshToken?.expired ?? true) == false else {
            self.loginSession?.accessToken = nil
            self.loginSession?.refreshToken = nil
            // TODO: Here we must notify of a logout action
            return
        }
        
        if (self.loginSession?.accessToken?.expired ?? true) == true {
            // Call an async method to renew the token
            let tenantHeaders = request.additionalHeaders.filter { (key, _) in
                key == "Tenant"
            }
            self.loginSession?.renew(additionalHeaders: tenantHeaders) { renewResult in
                switch renewResult {
                case .success(let tokens):
                    // Renewing worked! Add the token and move on
                    self.addTokenAndProceed(
                        tokens.accessToken,
                        to: request,
                        chain: chain,
                        response: response,
                        completion: completion
                    )
                case .failure(let error):
                    print(error)
                    chain.proceedAsync(
                        request: request,
                        response: response,
                        interceptor: self,
                        completion: completion
                    )
                }
            }
        } else {
            // We don't need to wait for renewal, add token and move on
            self.addTokenAndProceed(
                self.loginSession?.accessToken,
                to: request,
                chain: chain,
                response: response,
                completion: completion
            )
        }
    }
}
