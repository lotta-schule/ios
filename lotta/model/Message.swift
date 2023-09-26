//
//  Message.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Foundation
import LottaCoreAPI

class Message: Identifiable {
    var id: ID
    
    var user: User
    
    var content: String?
    
    var insertedAt: Date
    
    init(id: ID, user: User, content: String?, createdAt: Date) {
        self.id = id
        self.user = user
        self.content = content
        self.insertedAt = createdAt
    }
    
    convenience init(from graphQLResult: GetConversationQuery.Data.Conversation.Message, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            user: User(from: graphQLResult.user!, for: tenant),
            content: graphQLResult.content,
            createdAt: graphQLResult.insertedAt?.toDate() ?? Date.now
        )
    }
    
    convenience init(from graphQLResult: SendMessageMutation.Data.Message, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            user: User(from: graphQLResult.user!, for: tenant),
            content: graphQLResult.content,
            createdAt: graphQLResult.insertedAt?.toDate() ?? Date.now
        )
    }
    
    convenience init(from graphQLResult: ReceiveMessageSubscription.Data.Message, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            user: User(from: graphQLResult.user!, for: tenant),
            content: graphQLResult.content,
            createdAt: graphQLResult.insertedAt?.toDate() ?? Date.now
        )
    }
}

extension DateTime {
    func toDate() -> Date {
       ISO8601DateFormatter().date(from: self) ?? Date.now
    }
}

