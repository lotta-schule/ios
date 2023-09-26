//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 26/09/2023.
//

import SwiftUI

struct MainView : View {
    var onLogout: () -> ()
    var body: some View {
            TabView {
                MessagingView()
                    .badge(2)
                    .tabItem {
                        Label("Nachrichten", systemImage: "message")
                    }
                ProfileView(onLogout: onLogout)
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
            }
    }
}
