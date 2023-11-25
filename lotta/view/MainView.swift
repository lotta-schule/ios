//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 26/09/2023.
//

import SwiftUI
import Apollo

struct MainView : View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(UserSession.self) private var userSession
    
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
            userSession.loadConversations()
        }
        .onChange(of: scenePhase, initial: true, { _, phase in
            switch scenePhase {
            case .active:
                Task {
                    try? await userSession.subscribeToMessages()
                }
            case .background, .inactive:
                userSession.unsubscribeToMessages()
            default:
                print("Unknown phase \(phase)")
            }
        })
        .onAppear {
            Task {
                try? await userSession.subscribeToMessages()
            }
        }
        .onDisappear {
            userSession.unsubscribeToMessages()
        }
    }
}
