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
    @Environment(ModelData.self) var modelData: ModelData

    var body: some View {
        NavigationSplitView {
            ConversationsList(
                conversations: modelData.conversations,
                currentUser: modelData.currentSession?.user
            )
            .refreshable {
                await loadConversations()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
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
    
    private func loadConversations() async -> Void {
        do {
            try await modelData.loadConversations()
        } catch  {
            print(error)
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
        // .modelContainer(for: Item.self, inMemory: true)
}
