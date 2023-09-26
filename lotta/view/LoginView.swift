//
//  LoginView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct LoginView: View {
    var api: CoreApi
    var onResetTenant:  () -> ()
    var onLogin: ((User, String)) -> ()
    
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    
    var body: some View {
        VStack {
            if let url = api.tenant?.logoImageFileId?.getUrl() {
                AsyncImage(url: url)
                    .frame(width: 100, height: 100)
                    .padding(.top, 50)
                    .padding(.bottom, 75)
                    .scaledToFit()
            } else {
                Image(.lottaLogo)
                    .frame(width: 100, height: 100)
                    .padding(.top, 50)
                    .padding(.bottom, 75)
                    .scaledToFit()
            }
            
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .disabled(isLoading)
                .frame(maxWidth: 400)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .disabled(isLoading)
                .frame(maxWidth: 400)
                .onSubmit {
                    Task {
                        do {
                            let (user, token) = try await loginAsync()
                            onLogin((user, token))
                        } catch {
                            print("error \(error)")
                        }
                    }
                }
                
            Button(action: {
                Task {
                    do {
                        let (user, token) = try await loginAsync()
                        onLogin((user, token))
                    } catch {
                        print("error \(error)")
                    }
                }
            }) {
                Text("Login")
                    .frame(width: 200, height: 40) // Adjust the button size as needed
                    .background(isDisabled() ? .gray : .red)
                    .foregroundColor(isDisabled() ? .black : .white)
                    .cornerRadius(8)
                    .padding(.top, 20)
            }
            .disabled(isDisabled())
            
            
            Spacer()
            
            HStack(alignment: .bottom) {
                Button("Schule wechseln", systemImage: "chevron.backward") {
                    onResetTenant()
                }
                .padding(.leading, 16)
                Spacer()
            }
        }
        .background {
            if let url = api.tenant?.backgroundImageFileId?.getUrl() {
                AsyncImage(url: url)
                    .scaledToFill()
                    .opacity(0.25)
            } else {
                EmptyView()
            }
        }
    }
    
    func isDisabled() -> Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    func loginAsync() async throws -> (User, String) {
        isLoading = true
        do {
            let tokenGraphqlResult = try await api.apollo.performAsync(
                mutation: LoginMutation(username: email, password: password)
            )
            guard let token = tokenGraphqlResult.data?.login?.accessToken else {
                print("No token in response! \(tokenGraphqlResult)")
                throw NSError() //  TODO: Change this to error type when it's moved
            }
            let authenticatedApi = CoreApi(userToken: token, tenant: api.tenant)
            let userGraphqlResult = try await authenticatedApi.apollo.fetchAsync(
                query: GetCurrentUserQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            guard let userResult = userGraphqlResult.data?.currentUser else {
                print("No user in response! \(userGraphqlResult)")
                throw NSError() //  TODO: Change this to error type when it's moved
            }
            return (User(from: userResult, for: api.tenant!), token)
        } catch {
            print("Failure! Error: \(error)")
            self.isLoading = false
            throw error
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            api: CoreApi(
                userToken: nil,
                tenant: Tenant(id: "1", title: "Titel", slug: "test")
            ),
            onResetTenant: {},
            onLogin: { (_, _) in }
        )
        .environmentObject(ModelData(tenant: Tenant(id: "1", title: "Titel", slug: "test")))
    }
}
