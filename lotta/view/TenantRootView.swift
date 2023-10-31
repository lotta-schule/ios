//
//  TenantRootView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 20/10/2023.
//

import SwiftUI

struct TenantRootView: View {
    @Environment(UserSession.self) private var userSession
    
    var body: some View {
        MainView()
        .background {
            ZStack {
                userSession.theme.pageBackgroundColor
                if let url = userSession.tenant.backgroundImageFileId?.getUrl(for: userSession.tenant) {
                    AsyncImage(url: url)
                        .scaledToFill()
                        .opacity(0.25)
                        .ignoresSafeArea(.all)
                    
                } else {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    TenantRootView()
        .environment(UserSession(
            tenant: Tenant(id: "0", title: "Meine Schule", slug: "meine-schule"),
            authInfo: AuthInfo(),
            user: User(tenant: Tenant(id: "0", title: "Meine Schule", slug: "meine-schule"), id: "0")
        ))
}
