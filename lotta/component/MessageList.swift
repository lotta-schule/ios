//
//  MessageListView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct MessageList : View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    var conversation: Conversation
    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            ScrollView {
                ForEach(conversation.messages, id: \.id) { message in
                    MessageRow(message: message, fromCurrentUser: message.user.id == userSession.user.id)
                        .padding(.horizontal, CGFloat(userSession.theme.spacing))
                        .id(message.id)
                }
            }
            .navigationTitle(conversation.getName(excluding: userSession.user))
            .onChange(of: conversation.id, initial: true) { _, _ in
                Task {
                    do {
                        try await userSession.loadConversation(conversation)
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            .onChange(of: conversation.messages.count, initial: true) { _, _  in
                withAnimation {
                    scrollViewReader.scrollTo(conversation.messages.last?.id)
                }
            }
        }
    }
    
}
