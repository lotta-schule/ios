//
//  Conversation.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Foundation
import LottaCoreAPI

@Observable final class Conversation {
    var tenant: Tenant
    
    var id: ID
    
    var users: [User]
    
    var groups: [Group]
    
    var unreadMessages = 0
    
    var messages = [Message]()
    
    var updatedAt: Date
    
    init(tenant: Tenant, id: ID, users: [User], groups: [Group], messages: [Message], updatedAt: Date, unreadMessages: Int = 0) {
        self.tenant = tenant
        self.id = id
        self.users = users
        self.groups = groups
        self.messages = messages.sorted(by: { msg1, msg2 in
            msg1.insertedAt.compare(msg2.insertedAt) == .orderedAscending
        })
        self.updatedAt = updatedAt
        self.unreadMessages = 0
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationsQuery.Data.Conversation) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(in: tenant, from: $0) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? [],
            messages: [],
            updatedAt: graphQLResult.updatedAt?.toDate() ?? Date.now,
            unreadMessages: graphQLResult.unreadMessages ?? 0
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationQuery.Data.Conversation) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(in: tenant, from: $0) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? [],
            messages: graphQLResult.messages?.map { Message(in: tenant, from: $0) } ?? [],
            updatedAt: graphQLResult.updatedAt?.toDate() ?? Date.now,
            unreadMessages: graphQLResult.unreadMessages ?? 0
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: ReceiveMessageSubscription.Data.Message.Conversation) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(in: tenant, from: $0) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? [],
            messages: [],
            updatedAt: graphQLResult.updatedAt?.toDate() ?? Date.now,
            unreadMessages: graphQLResult.unreadMessages ?? 0
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: SendMessageMutation.Data.Message.Conversation, withUsers users: [User], andGroups groups: [Group]) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            users: users,
            groups: groups,
            messages: [],
            updatedAt: graphQLResult.updatedAt?.toDate() ?? Date.now
        )
    }
    
    func getImageUrl(excluding excludedUser: User?) -> URL? {
        return users
            .filter { $0.id != excludedUser?.id }
            .first(where: { $0.id != excludedUser?.id })?
            .avatarImageFileId?
            .getUrl(for: tenant)
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

extension Conversation: Identifiable {}

extension Conversation: Hashable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
        
    }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
}
