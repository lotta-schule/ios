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
                ),
                size: 34
            )
            .scaledToFit()
            VStack(alignment: .leading) {
                Text(ConversationUtil.getTitle(for: conversation, excludingUserId: userSession.user.id))
                if let updated = conversation.updatedAt?.toDate() {
                    Text(timeElapsed(since: updated))
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
                .badge(conversation.unreadMessages ?? 0)
        }
    }
    
    private func timeElapsed(since date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .spellOut
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
}
