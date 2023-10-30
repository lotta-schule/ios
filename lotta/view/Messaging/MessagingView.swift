//
//  ContentView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import SwiftUI
import SwiftData
import LottaCoreAPI

struct MessagingView: View {
    @Environment(UserSession.self) var userSession: UserSession
    @Environment(RouterData.self) var routerData: RouterData
    @State private var messagePath = [String]()
    
    var body: some View {
        NavigationSplitView(sidebar: {
            ConversationsList()
            .refreshable {
                try? await userSession.loadConversations()
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }, detail: {
            if let conversationId = routerData.selectedConversationId,
               let conversation = userSession.conversations.first(where: { $0.id == conversationId }) {
                ConversationView(conversation: conversation)
            } else {
                Text("Unterhaltung wählen")
            }
        })
    }
    
    private func addItem() {
        withAnimation {
            // let newItem = Item(timestamp: Date())
            // modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // for index in offsets {
                // modelContext.delete(items[index])
            // }
        }
    }
}

#Preview {
    MessagingView()
        .environment(
            UserSession(
                tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"),
                authInfo: AuthInfo(),
                user: User(id: "0")
            )
        )
        .environment(RouterData.shared)
}
