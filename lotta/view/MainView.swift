//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 26/09/2023.
//

import SwiftUI

struct MainView : View {
    @Environment(ModelData.self) var modelData: ModelData
    
    var body: some View {
            TabView {
                MessagingView()
                    .badge(modelData.unreadMessageCount)
                    .tabItem {
                        Label("Nachrichten", systemImage: "message")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
            }
            .onAppear {
                Task {
                    try? await modelData.loadConversations()
                }
                modelData.subscribeToMessages()
            }
    }
}
