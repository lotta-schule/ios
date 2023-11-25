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
    
    var messages: [GetConversationQuery.Data.Conversation.Message]
    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            ScrollView {
                ForEach(messages, id: \.id.unsafelyUnwrapped) { message in
                    MessageRow(
                        message: message,
                        fromCurrentUser: message.user?.id == userSession.user.id
                    )
                    .padding(.horizontal, CGFloat(userSession.theme.spacing))
                    .id(message.id)
                }
            }
            .onChange(of: messages.count, initial: true) { _, _  in
                withAnimation {
                    scrollViewReader.scrollTo(messages.last?.id)
                }
            }
        }
    }
    
}
