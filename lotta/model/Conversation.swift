//
//  Conversation.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Foundation
import LottaCoreAPI

class Conversation: Identifiable {
    var id: ID
    
    var users: [User]
    
    var groups: [Group]
    
    var unreadMessages = 0
    
    var messages: [Message]
    
    init(id: ID, users: [User], groups: [Group], messages: [Message]? = []) {
        self.id = id
        self.users = users
        self.groups = groups
        self.messages = (messages ?? []).sorted(by: { msg1, msg2 in
            msg1.insertedAt.compare(msg2.insertedAt) == .orderedAscending
        })
    }
    
    convenience init(from graphQLResult: GetConversationsQuery.Data.Conversation, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(from: $0, for: tenant) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? []
        )
        if let unreadMessages = graphQLResult.unreadMessages {
            self.unreadMessages = unreadMessages
        }
    }
    
    convenience init(from graphQLResult: GetConversationQuery.Data.Conversation, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(from: $0, for: tenant) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? [],
            messages: graphQLResult.messages?.map { Message(from: $0, for: tenant) }
        )
    }
    
    func getImageUrl(excluding excludedUser: User?) -> URL? {
        return users
            .filter { $0.id != excludedUser?.id }
            .first(where: { $0.id != excludedUser?.id })?
            .avatarImageFileId?
            .getUrl(queryItems: [.init(name: "width", value: "100")])
    }
    
    
    func getName(excluding excludedUser: User?) -> String {
        if let group = groups.first {
            return group.name
        }
        if let user = users.first(where: { $0.id != excludedUser?.id }) {
            return user.visibleName
        }
            
        return "?"
    }
}
