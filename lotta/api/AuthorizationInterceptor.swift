import Foundation
import Apollo
import ApolloAPI
import JWTDecode

class AuthorizationInterceptor: ApolloInterceptor {
    enum UserError: Error {
        case noUserLoggedIn
    }
    
    public var id: String = UUID().uuidString
    
    private var loginSession: AuthInfo?
    
    init(loginSession: AuthInfo?) {
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
        // If the user has neither an access token nor a refresh token, don't bother
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
        // If we have an expired refresh token, we abort
        // If the refresh token is valid or there is no refresh token, we continue
        guard (self.loginSession?.refreshToken?.expired ?? false) == false else {
            self.loginSession?.accessToken = nil
            self.loginSession?.refreshToken = nil
            // TODO: Here we must notify of a logout action
            chain.handleErrorAsync(
                UserError.noUserLoggedIn,
                request: request,
                response: response,
                completion: completion
            )
            return
        }
        
        // We now know we have:
        //  - either no refreshtoken but some accessToken
        //  - A valid refresh token and maybe an access token
        // This means, if:
        //  - there is no access token or it is not valid, try to renew with the refresh Token
        // else
        //  - the access token ssems valid, just use it
        if (self.loginSession?.accessToken?.expired ?? true) == true {
            // Call an async method to renew the token
            self.loginSession?.renew() { renewResult in
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
