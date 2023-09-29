//
//  MessageListView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct MessageListView : View {
    @Environment(ModelData.self) private var modelData: ModelData
    
    var conversation: Conversation
    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            ScrollView {
                ForEach(conversation.messages, id: \.id) { message in
                    MessageRow(
                        message: message,
                        fromCurrentUser: message.user.id == modelData.currentSession?.user?.id
                    )
                    .padding(.horizontal, CGFloat(modelData.theme.spacing))
                    .id(message.id)
                }
            }
            .navigationTitle(conversation.getName(excluding: modelData.currentSession?.user))
            .task {
                do {
                    try await modelData.loadConversation(conversation)
                } catch {
                    print("Error: \(error)")
                }
            }
            .onChange(of: conversation.messages.count, initial: true) { _, _  in
                scrollViewReader.scrollTo(conversation.messages.last?.id)
            }
                
        }
            
        MessageInput(
            user: conversation.users.first(where: { $0.id != modelData.currentSession?.user?.id }),
            group: conversation.groups.first
        ) { message in
            withAnimation(.bouncy) {
                self.modelData.addMessage(message, toConversation: conversation)
            }
        }

    }
    
}
