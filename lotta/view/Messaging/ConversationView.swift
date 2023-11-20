//
//  MessageListView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct ConversationView : View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    var conversationId: ID
    
    var body: some View {
        if let conversation = userSession.conversations.first(where: { $0.id == conversationId }) {
            VStack {
                MessageList(conversationId: conversationId)
                
                MessageInput(
                    user: conversation.users.first(where: { $0.id != userSession.user.id }),
                    group: conversation.groups.first
                ) { (message, _) in
                    withAnimation(.bouncy) {
                        self.userSession.addMessage(message, toConversation: conversation)
                    }
                }
            }
            .navigationTitle(conversation.getName(excluding: userSession.user))
        } else {
            Text("Unterhaltung nicht gefunden")
        }
    }
}
