//
//  ConversationListItem.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//

import SwiftUI

struct ConversationListItem: View {
    var conversation: Conversation
    var excluding: User?
    var body: some View {
        HStack {
            Avatar(url: conversation.getImageUrl(excluding: excluding))
                .scaledToFit()
            Text(conversation.getName(excluding: excluding))
                .badge(conversation.unreadMessages)
        }
    }
}
