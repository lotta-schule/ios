//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 26/09/2023.
//

import SwiftUI
import Apollo

struct MainView : View {
    @Environment(UserSession.self) var userSession: UserSession
    
    @State private var cancelMessageSubscription: Cancellable?
    
    var body: some View {
            TabView {
                MessagingView()
                    .badge(userSession.unreadMessageCount)
                    .tabItem {
                        Label("Nachrichten", systemImage: "message")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
            }
            .tint(userSession.theme.primaryColor)
            .onChange(of: userSession, initial: true) { _, _ in
                Task {
                    try? await userSession.loadConversations()
                }
            }
            .onAppear {
                Task {
                    try? await userSession.loadConversations()
                }
                cancelMessageSubscription = userSession.subscribeToMessages()
            }
            .onDisappear {
                if let cancelMessageSubscription = cancelMessageSubscription {
                    cancelMessageSubscription.cancel()
                }
            }
    }
}
