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
    
    @State private var sortedMessages: [GetConversationQuery.Data.Conversation.Message] = []
    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            ScrollView {
                LazyVStack {
                    ForEach(sortedMessages, id: \.id.unsafelyUnwrapped) { message in
                        MessageRow(
                            message: message,
                            fromCurrentUser: message.user?.id == userSession.user.id
                        )
                        .padding(.horizontal, CGFloat(userSession.theme.spacing))
                        .id(message.id)
                    }
                }
            }
            .onChange(of: sortedMessages.last, initial: true) { oldLastElement, newLastElement  in
                if oldLastElement == nil {
                    scrollViewReader.scrollTo(newLastElement?.id)
                } else {
                    withAnimation {
                        scrollViewReader.scrollTo(newLastElement?.id)
                    }
                }
            }
        }
        .onChange(of: messages, initial: true) {
            sortedMessages = messages.sorted(by: {
                let d1 = $0.updatedAt?.toDate() ?? Date()
                let d2 = $1.updatedAt?.toDate() ?? Date()
                return d1.compare(d2) == .orderedAscending
            })
        }
    }
    
}
