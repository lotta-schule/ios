//
//  ConversationUtil.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 25/11/2023.
//

import Foundation
import LottaCoreAPI

struct ConversationUtil {
    private init() {}
    static func getTitle(
        for conversation: GetConversationQuery.Data.Conversation,
        excludingUserId: ID? = nil
    ) -> String {
        if let group = conversation.groups?.first {
            return group.name ?? "? Unbekannte Gruppe ?"
        }
        if let user = conversation.users?.first(where: { $0.id != excludingUserId }) {
            return UserUtil.getVisibleName(for: user)
        }
            
        return "?"
    }
    
    static func getTitle(
        for conversation: GetConversationsQuery.Data.Conversation,
        excludingUserId: ID? = nil
    ) -> String {
        if let group = conversation.groups?.first {
            return group.name ?? "? Unbekannte Gruppe ?"
        }
        if let user = conversation.users?.first(where: { $0.id != excludingUserId }) {
            return UserUtil.getVisibleName(for: user)
        }
            
        return "?"
    }
    
    static func getImage(
        for conversation: GetConversationsQuery.Data.Conversation,
        excludingUserId: ID? = nil,
        in tenant: Tenant
    ) -> URL? {
        return conversation.users?
            .filter { $0.id != excludingUserId }
            .first(where: { $0.id != excludingUserId })?
            .avatarImageFile?.id?
            .getUrl(for: tenant)
    }
}
