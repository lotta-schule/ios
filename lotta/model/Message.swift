//
//  Message.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Foundation
import LottaCoreAPI

final class Message {
    var tenant: Tenant
    
    var id: ID
    
    var user: User
    
    var content: String?
    
    var files: [LottaFile]
    
    var insertedAt: Date
    
    init(tenant: Tenant, id: ID, user: User, content: String?, createdAt: Date, files: [LottaFile]) {
        self.tenant = tenant
        self.id = id
        self.user = user
        self.content = content
        self.insertedAt = createdAt
        self.files = files
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationQuery.Data.Conversation.Message) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            user: User(in: tenant, from: graphQLResult.user!),
            content: graphQLResult.content,
            createdAt: graphQLResult.insertedAt?.toDate() ?? Date.now,
            files: graphQLResult.files?.compactMap {
                guard let data = $0 else {
                    return nil
                }
                return LottaFile(in: tenant, from: data)
            } ?? []
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: SendMessageMutation.Data.Message) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            user: User(in: tenant, from: graphQLResult.user!),
            content: graphQLResult.content,
            createdAt: graphQLResult.insertedAt?.toDate() ?? Date.now,
            files: graphQLResult.files?.compactMap {
                guard let data = $0 else {
                    return nil
                }
                return LottaFile(in: tenant, from: data)
            } ?? []
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: ReceiveMessageSubscription.Data.Message) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            user: User(in: tenant, from: graphQLResult.user!),
            content: graphQLResult.content,
            createdAt: graphQLResult.insertedAt?.toDate() ?? Date.now,
            files: []
        )
    }
}

extension DateTime {
    func toDate() -> Date {
       ISO8601DateFormatter().date(from: self) ?? Date.now
    }
}

extension Message: Hashable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
