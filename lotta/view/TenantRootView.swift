//
//  TenantRootView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 20/10/2023.
//

import SwiftUI
import NukeUI

struct TenantRootView: View {
    @Environment(UserSession.self) private var userSession
    
    var body: some View {
        MainView()
        .background {
            ZStack {
                userSession.theme.pageBackgroundColor.toColor()
                if let url = userSession.tenant.backgroundImageFileId?.getUrl(for: userSession.tenant)?.appending(queryItems: [.init(name: "height", value: "800")]) {
                    LazyImage(url: url)
                        .scaledToFit()
                        .opacity(0.25)
                        .ignoresSafeArea(.all)
                        .blur(radius: 10)
                    
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
