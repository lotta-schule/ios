//
//  MessageListView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct MessageListView : View {
    var conversation: Conversation
    
    @EnvironmentObject var modelData: ModelData
    
    @State var messages = [Message]()
    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            ScrollView {
                ForEach(messages) { message in
                    MessageRow(message: message, fromCurrentUser: message.user.id == modelData.currentUser.id)
                        .id(message.id)
                }
            }
            .navigationTitle(conversation.getName(excluding: modelData.currentUser))
            .task {
                await loadConversation()
            }
            .onChange(of: messages.count, initial: true) { _, _  in
                scrollViewReader.scrollTo(messages.last?.id)
            }
                
        }
            
        MessageInput(
            user: conversation.users.first(where: { $0.id != modelData.currentUser.id }),
            group: conversation.groups.first
        ) { message in
            withAnimation(.bouncy) {
                messages.append(message)
            }
        }
        .onAppear {
            _ = modelData.api.apollo.subscribe(
                subscription: ReceiveMessageSubscription()) {
                    switch $0 {
                        case .success(let graphqlResult):
                            if let conversationId = graphqlResult.data?.message?.conversation?.id {
                                if self.conversation.id == conversationId {
                                    if let messageData = graphqlResult.data?.message {
                                        self.messages.append(Message(from: messageData, for: modelData.api.tenant!))
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Error subscribing: \(error)")
                    }
                }
        }

    }
    
    private func loadConversation() async -> Void {
        do {
            let result = try await modelData.api.apollo.fetchAsync(query: GetConversationQuery(id: conversation.id), cachePolicy: .fetchIgnoringCacheData)
            if let conversation = result.data?.conversation {
                let loadedConversation = Conversation(from: conversation, for: modelData.api.tenant!)
                messages.removeAll()
                loadedConversation.messages.forEach { message in
                    messages.append(message)
                }
            }
        } catch  {
            print(error)
        }
    }
}
