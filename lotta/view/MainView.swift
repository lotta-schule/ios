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
                Task {
                    try? await userSession.loadConversations()
                }
            }
            .onChange(of: scenePhase, initial: true, { _, phase in
                switch scenePhase {
                    case .active:
                        if cancelMessageSubscription == nil {
                            cancelMessageSubscription = userSession.subscribeToMessages()
                        }
                    case .inactive, .background:
                        if let cancelMessageSubscription = cancelMessageSubscription {
                            cancelMessageSubscription.cancel()
                            self.cancelMessageSubscription = nil
                        }
                    default:
                        print("Unknown phase \(phase)")
                }
            })
            .onAppear {
                Task {
                    try? await userSession.loadConversations()
                }
                if cancelMessageSubscription == nil {
                    cancelMessageSubscription = userSession.subscribeToMessages()
                }
            }
            .onDisappear {
                if let cancelMessageSubscription = cancelMessageSubscription {
                    cancelMessageSubscription.cancel()
                    self.cancelMessageSubscription = nil
                }
            }
    }
}
