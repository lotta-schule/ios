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
                        fromCurrentUser: message.user.id == modelData.currentUser?.id
                    )
                    .padding(.horizontal, CGFloat(modelData.theme.spacing))
                    .id(message.id)
                }
            }
            .navigationTitle(conversation.getName(excluding: modelData.currentUser))
            .onChange(of: conversation.id, initial: true) { _, _ in
                Task {
                    do {
                        try await modelData.loadConversation(conversation)
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            .onChange(of: conversation.messages.count, initial: true) { _, _  in
                scrollViewReader.scrollTo(conversation.messages.last?.id)
            }
                
        }
            
        MessageInput(
            user: conversation.users.first(where: { $0.id != modelData.currentUser?.id }),
            group: conversation.groups.first
        ) { message in
            withAnimation(.bouncy) {
                self.modelData.addMessage(message, toConversation: conversation)
            }
        }

    }
    
}
