//
//  LoginView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct LoginView: View {
    @Environment(ModelData.self) var modelData: ModelData
    @AppStorage("lotta-tenant-slug") var currentTenantSlug = ""
    
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    
    
    var body: some View {
        VStack {
            if let url = modelData.currentTenant?.logoImageFileId?.getUrl() {
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
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .disabled(isLoading)
                .frame(maxWidth: 400)
            
            SecureField("Password", text: $password)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .disabled(isLoading)
                .frame(maxWidth: 400)
                .onSubmit(onSubmit)
                
            Button(action: onSubmit) {
                Text("Login")
                    .foregroundStyle(
                        modelData.currentTenant?.getThemeColor(forKey: "primaryColor") ?? .primary
                    )
                    .frame(width: 200, height: 40) // Adjust the button size as needed
                    .background(isDisabled() ? .white : modelData.currentTenant?.getThemeColor(forKey: "primaryColor"))
                    .foregroundColor(
                        isDisabled() ?
                            modelData.currentTenant?.getThemeColor(forKey: "disabledColor") :
                            modelData.currentTenant?.getThemeColor(forKey: "textContrastColor")
                        )
                    .cornerRadius(8)
                    .padding(.top, 20)
            }
            .disabled(isDisabled())
            
            Spacer()
            
            HStack(alignment: .bottom) {
                Button("Schule wechseln", systemImage: "chevron.backward") {
                    modelData.reset()
                }
                .padding(.leading, 16)
                Spacer()
            }
        }
        .onAppear(perform: {
            let color = modelData.currentTenant?.getThemeColor(forKey: "disabledColor")
            print("primary: \(String(describing: color))")
        })
    }
    
    func onSubmit() -> Void {
        Task {
            do {
                let (user, token) = try await loginAsync()
                let session = LoginSession(user: user, token: token)
                modelData.setSession(session)
            } catch {
                print("error \(error)")
            }
        }
    }
    
    func isDisabled() -> Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    func loginAsync() async throws -> (User, String) {
        isLoading = true
        do {
            let tokenGraphqlResult = try await modelData.api.apollo.performAsync(
                mutation: LoginMutation(username: email, password: password)
            )
            guard let token = tokenGraphqlResult.data?.login?.accessToken else {
                print("No token in response! \(tokenGraphqlResult)")
                throw NSError() //  TODO: Change this to error type when it's moved
            }
            let authenticatedApi = CoreApi(withTenantSlug: modelData.currentTenant!.slug, authToken: token)
            let userGraphqlResult = try await authenticatedApi.apollo.fetchAsync(
                query: GetCurrentUserQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            guard let userResult = userGraphqlResult.data?.currentUser else {
                print("No user in response! \(userGraphqlResult)")
                throw NSError() //  TODO: Change this to error type when it's moved
            }
            return (User(from: userResult), token)
        } catch {
            print("Failure! Error: \(error)")
            self.isLoading = false
            throw error
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
        .environment(ModelData())
    }
}
