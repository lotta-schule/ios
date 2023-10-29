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

    var body: some View {
        NavigationSplitView {
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
        } detail: {
            Text("Select an item")
        }
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
}
