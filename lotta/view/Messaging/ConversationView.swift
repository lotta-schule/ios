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
    
    var conversation: Conversation
    
    var body: some View {
        VStack {
            MessageList(conversation: conversation)
            
            MessageInput(
                user: conversation.users.first(where: { $0.id != userSession.user.id }),
                group: conversation.groups.first
            ) { message in
                withAnimation(.bouncy) {
                    self.userSession.addMessage(message, toConversation: conversation)
                }
            }
        }
    }
}
