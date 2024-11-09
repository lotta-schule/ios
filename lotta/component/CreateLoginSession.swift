//
//  LoginView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import Sentry
import SwiftUI
import LottaCoreAPI
import NukeUI

struct TenantDescriptor: Codable, Hashable {
    let id: Int
    let title: String
    let slug: String
    let logoImageFileId: ID?
    let backgroundImageFileId: ID?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ListTenantsResult: Codable {
    let success: Bool
    let error: String?
    let tenants: [TenantDescriptor]?
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedTenantDescriptor: TenantDescriptor?
    @State private var availableTenantDescriptors: [TenantDescriptor] = []
    @State private var isLoadingTenants = false
    @State private var isLoading = false
    @State private var isAlertViewPresented = false
    @State private var lastErrorMessage = ""
    
    var disablingTenantSlugs: [String] = []
    var defaultLoginMail: String = ""
    var onLogin: (UserSession) -> Void
    
    var body: some View {
        VStack {
            Text("Anmelden")
                .font(.title)
                .padding(.vertical)
            
            if let logoImageFileId = selectedTenantDescriptor?.logoImageFileId,
               let url = String(logoImageFileId).getUrl(for: Tenant(
                id: String(selectedTenantDescriptor!.id),
                title: selectedTenantDescriptor!.title,
                slug: selectedTenantDescriptor!.slug
               ), queryItems: [
                URLQueryItem(name: "width", value: "200"),
                URLQueryItem(name: "height", value: "100")
               ]) {
                LazyImage(url: url)
                    .padding(8)
                    .frame(width: 200, height: 100)
            }
            
            Form {
                LabeledContent {
                    TextField("Email", text: $email)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .disabled(isLoading || selectedTenantDescriptor != nil)
                        .onSubmit { fetchPossibleTenants() }
                } label: {
                    Text("Email:")
                }
                
                if availableTenantDescriptors.count > 1 {
                    Picker("Schule", selection: $selectedTenantDescriptor) {
                        ForEach(availableTenantDescriptors, id: \.id) {
                            Text($0.title).tag($0 as TenantDescriptor?)
                        }
                    }
                }
                
                if availableTenantDescriptors.count > 0 {
                    LabeledContent {
                        SecureField("Passwort", text: $password)
                            .multilineTextAlignment(.trailing)
                            .textContentType(.password)
                            .disabled(isLoading)
                            .onSubmit(onSubmit)
                    } label: {
                        Text("Passwort:")
                    }
                }
            }
            .frame(maxWidth: 400, alignment: .center)
            .scrollContentBackground(.hidden)
            .alert(lastErrorMessage, isPresented: $isAlertViewPresented) {}
            
            
            if availableTenantDescriptors.count == 0 {
                LottaButton("weiter", action: fetchPossibleTenants, isLoading: isLoadingTenants)
                    .disabled(isLoadingTenants || email.isEmpty)
                    .padding()
            }
            
            if selectedTenantDescriptor != nil {
                LottaButton("anmelden", action: onSubmit, isLoading: isLoading)
                    .disabled(isDisabled())
                    .padding()
            }
            
            
        }
        .preferredColorScheme(.light)
        .animation(.spring(), value: selectedTenantDescriptor)
        .onAppear() {
            email = defaultLoginMail
        }
    }
    
    func fetchPossibleTenants() -> Void {
        withAnimation {
            isLoadingTenants = true
        }
        let url = LOTTA_API_HTTP_URL
            .appending(path: "/api/public/user-tenants")
            .appending(queryItems: [URLQueryItem(name: "username", value: email)])
        print(url)
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let data = try? JSONDecoder().decode(ListTenantsResult.self, from: data) {
                guard let tenants = data.tenants?.filter({ td in
                    !disablingTenantSlugs.contains(where: { $0 == td.slug })
                  }),
                  !tenants.isEmpty else {
                      showErrorMessage("Kein Benutzerkonto gefunden")
                      return
                  }
                withAnimation {
                    self.availableTenantDescriptors = tenants
                    self.selectedTenantDescriptor = tenants[0]
                }
                saveTenantDescriptorsToDisk(results: data)
            } else if let error = error {
                SentrySDK.capture(error: error)
                showErrorMessage(error.localizedDescription)
                print(error)
            } else {
                showErrorMessage("Keine Verbindung zum Netzwerk")
                print("Fehler: Unexpected error")
            }
            isLoadingTenants = false
        } .resume()
    }
    
    func saveTenantDescriptorsToDisk(results: ListTenantsResult) -> Void {
        let resultsData = try? JSONEncoder().encode(results)
        let jsonFileURL = baseCacheDirURL.appendingPathComponent("tenants-list.json")
        
        try? resultsData?.write(to: jsonFileURL)
    }
    
    func onSubmit() -> Void {
        Task {
            isLoading = true
            do {
                let userSession = try await UserSession.createFromCredentials(
                    onTenantSlug: selectedTenantDescriptor!.slug,
                    withUsername: email,
                    andPassword: password
                )
                onLogin(userSession)
            } catch {
                lastErrorMessage = error.localizedDescription
                isAlertViewPresented = true
            }
            isLoading = false
        }
    }
    
    func isDisabled() -> Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    func showErrorMessage(_ message: String) -> Void {
        lastErrorMessage = message
        isAlertViewPresented = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView() { userSession in
            print("Logged in as \(userSession.user.visibleName)")
        }
    }
}
