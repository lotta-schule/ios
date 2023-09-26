//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct RootView: View {
    @AppStorage("lotta-tenant-slug") var currentTenantSlug = ""
    
    @State var currentTenant: Tenant? = nil
    @State var session: LoginSession? = nil
    
    var body: some View {
        HStack {
            if currentTenant == nil {
                if currentTenantSlug.isEmpty {
                    SelectTenantView { tenant in
                        currentTenantSlug = tenant.slug
                    }
                } else {
                    ProgressView()
                }
            } else if session == nil {
                LoginView(
                    api: CoreApi(userToken: nil, tenant: currentTenant),
                    onResetTenant: {
                        currentTenantSlug = ""
                    }
                ) { result in
                    self.session = LoginSession(user: result.0, token: result.1)
                }
            } else {
                MainView(onLogout: {
                    session = nil
                })
                .environmentObject(
                    ModelData(tenant: currentTenant!, session: session!)
                )
            }
        }
        .onChange(of: currentTenantSlug, initial: true) {
            Task {
                if currentTenant?.slug != currentTenantSlug {
                    currentTenant = nil
                    let api = CoreApi(userToken: nil, tenant: Tenant(id: "", title: "", slug: currentTenantSlug))
                    do {
                        let graphqlResponse = try await api.apollo.fetchAsync(query: GetTenantQuery(), cachePolicy: .fetchIgnoringCacheData)
                        if let tenant = graphqlResponse.data?.tenant {
                            let tenant = Tenant(from: tenant)
                            currentTenant = tenant
                        } else {
                            currentTenantSlug = ""
                        }
                    } catch {
                        print("Error fetching tenant: \(error)")
                        currentTenantSlug = ""
                    }
                }
                print("currentTenantSlug: \(currentTenantSlug)")
            }
        }
    }
    
}
