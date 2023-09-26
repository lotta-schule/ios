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
    @EnvironmentObject var modelData: ModelData
    @State var conversations: [Conversation] = []
    // @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            ConversationsList(
                conversations: conversations,
                currentUser: modelData.currentUser
            )
            .refreshable {
                await loadConversations()
            }
            .task {
                await self.loadConversations()
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
        .onAppear {
            _ = modelData.api.apollo.subscribe(
                subscription: ReceiveMessageSubscription()) {
                    switch $0 {
                        case .success(let graphqlResult):
                        if let conversationId = graphqlResult.data?.message?.conversation?.id {
                            if self.conversations.contains(where: { $0.id == conversationId }) {
                                self.conversations = self.conversations.map({ conversation in
                                    if conversation.id == conversationId {
                                        let updatedConversation = Conversation(
                                            id: conversation.id,
                                            users: conversation.users,
                                            groups: conversation.groups,
                                            messages: conversation.messages
                                        )
                                        updatedConversation.unreadMessages = conversation.unreadMessages + 1
                                        return updatedConversation
                                    } else {
                                        return conversation
                                    }
                                })
                            }
                        }
                        case .failure(let error):
                            print("Error subscribing: \(error)")
                    }
                }
        }
    }
    
    private func loadConversations() async -> Void {
        do {
            let result = try await modelData.api.apollo.fetchAsync(query: GetConversationsQuery(), cachePolicy: .fetchIgnoringCacheData)
            if let conversations =
                result.data?.conversations?.filter({ conversation in
                    conversation != nil
                }).map({ Conversation(from: $0!, for: modelData.api.tenant!) }) {
                    self.conversations = conversations
                }
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
