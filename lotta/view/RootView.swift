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
    
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        HStack {
            if modelData.currentTenant == nil {
                if currentTenantSlug.isEmpty {
                    SelectTenantView { tenant in
                        currentTenantSlug = tenant.slug
                    }
                } else {
                    ProgressView()
                }
            } else if modelData.currentUser == nil {
                LoginView()
            } else {
                MainView()
            }
        }
        .preferredColorScheme(.light)
        .tint(modelData.theme.primaryColor)
        .background {
            ZStack {
                modelData.theme.pageBackgroundColor
                if let url = modelData.currentTenant?.backgroundImageFileId?.getUrl() {
                    AsyncImage(url: url)
                        .scaledToFill()
                        .opacity(0.25)
                        .ignoresSafeArea(.all)
                    
                } else {
                    EmptyView()
                }
            }
        }
        .onChange(of: currentTenantSlug, initial: true) {
            Task {
                if modelData.currentTenant?.slug != currentTenantSlug {
                    modelData.reset(keepCurrentTenantSlug: true)
                    let api = CoreApi(withTenantSlug: currentTenantSlug)
                    do {
                        let graphqlResponse = try await api.apollo.fetchAsync(query: GetTenantQuery(), cachePolicy: .fetchIgnoringCacheData)
                        if let tenant = graphqlResponse.data?.tenant {
                            let tenant = Tenant(from: tenant)
                            modelData.setTenant(tenant)
                        } else {
                            currentTenantSlug = ""
                        }
                    } catch {
                        print("Error fetching tenant: \(error)")
                        currentTenantSlug = ""
                    }
                }
            }
        }
    }
    
}
