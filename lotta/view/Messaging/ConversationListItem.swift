//
//  ConversationListItem.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct ConversationListItem: View {
    @Environment(UserSession.self) private var userSession
    
    var conversationId: ID
    
    var excluding: User?
    
    var body: some View {
        if let conversation = userSession.conversations.first(where: { $0.id == conversationId }) {
            HStack {
                Avatar(url: conversation.getImageUrl(excluding: excluding))
                    .scaledToFit()
                Text(conversation.getName(excluding: excluding))
                    .badge(conversation.unreadMessages ?? 0)
            }
        } else {
            EmptyView()
        }
    }
}
