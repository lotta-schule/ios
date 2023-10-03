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
            
            LottaButton(action: onSubmit)
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
    }
    
    func onSubmit() -> Void {
        Task {
            do {
                try await loginAsync()
            } catch {
                print("error \(error)")
            }
        }
    }
    
    func isDisabled() -> Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    func loginAsync() async throws -> Void {
        isLoading = true
        do {
            _ = try await modelData.authenticate(username: email, password: password)
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
