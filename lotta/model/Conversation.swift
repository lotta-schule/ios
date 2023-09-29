//
//  Conversation.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Foundation
import LottaCoreAPI

@Observable final class Conversation {
    var id: ID
    
    var users: [User]
    
    var groups: [Group]
    
    var unreadMessages = 0
    
    var messages = [Message]()
    
    var updatedAt: Date
    
    init(id: ID, users: [User], groups: [Group], messages: [Message], updatedAt: Date) {
        self.id = id
        self.users = users
        self.groups = groups
        self.messages = messages.sorted(by: { msg1, msg2 in
            msg1.insertedAt.compare(msg2.insertedAt) == .orderedAscending
        })
        self.updatedAt = updatedAt
    }
    
    convenience init(from graphQLResult: GetConversationsQuery.Data.Conversation) {
        self.init(
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(from: $0) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? [],
            messages: [],
            updatedAt: graphQLResult.updatedAt?.toDate() ?? Date.now
        )
        if let unreadMessages = graphQLResult.unreadMessages {
            self.unreadMessages = unreadMessages
        }
    }
    
    convenience init(from graphQLResult: GetConversationQuery.Data.Conversation) {
        self.init(
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(from: $0) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? [],
            messages: graphQLResult.messages?.map { Message(from: $0) } ?? [],
            updatedAt: graphQLResult.updatedAt?.toDate() ?? Date.now
        )
    }
    
    convenience init(from graphQLResult: ReceiveMessageSubscription.Data.Message.Conversation) {
        self.init(
            id: graphQLResult.id!,
            users: graphQLResult.users?.map { User(from: $0) } ?? [],
            groups: graphQLResult.groups?.map { Group(from: $0) } ?? [],
            messages: [],
            updatedAt: graphQLResult.updatedAt?.toDate() ?? Date.now
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
