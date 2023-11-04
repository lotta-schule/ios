//
//  MessageListView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Sentry
import SwiftUI
import LottaCoreAPI

struct MessageList : View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    var conversationId: ID
    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            if let conversation = userSession.conversations.first(where: { $0.id == conversationId }) {
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
                            SentrySDK.capture(error: error)
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
    
}
