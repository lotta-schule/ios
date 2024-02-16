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
    
    var conversation: GetConversationsQuery.Data.Conversation
    
    var body: some View {
        HStack {
            Avatar(
                url: ConversationUtil.getImage(
                    for: conversation,
                    excludingUserId: userSession.user.id,
                    in: userSession.tenant
                )
            )
            .scaledToFit()
            Text(ConversationUtil.getTitle(for: conversation, excludingUserId: userSession.user.id))
                .badge(conversation.unreadMessages ?? 0)
        }
    }
    
}
