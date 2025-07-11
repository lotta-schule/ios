//
//  User.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 21/09/2023.
//

import Sentry
import SwiftData
import LottaCoreAPI

typealias SentryUser = Sentry.User

final class User {
    var tenant: Tenant
    
    var id: ID
    
    var name: String?
    
    var nickname: String?
    
    var email: String?
    
    var groups: [Group]?
    
    var avatarImageFile: String?
    
    init(tenant: Tenant, id: ID, email: String? = nil, name: String? = nil, nickname: String? = nil, groups: [Group]? = nil, avatarImageFile: String? = nil) {
        self.tenant = tenant
        self.id = id
        self.email = email
        self.name = name
        self.nickname = nickname
        self.groups = groups
        self.avatarImageFile = avatarImageFile
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetCurrentUserQuery.Data.CurrentUser) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            email: graphQLResult.email,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            groups: graphQLResult.groups.map { Group(from: $0) },
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationsQuery.Data.Conversation.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationQuery.Data.Conversation.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationQuery.Data.Conversation.Message.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: SearchUsersQuery.Data.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: SendMessageMutation.Data.Message.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: ReceiveMessageSubscription.Data.Message.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: ReceiveMessageSubscription.Data.Message.Conversation.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFile: graphQLResult.avatarImageFile?.formats.first { format in
                !format.url.isEmpty
            }?.url
        )
    }
    
    var visibleName: String {
        guard let name = name, !name.isEmpty else {
            return nickname ?? "?"
        }
        if let nickname = nickname, !nickname.isEmpty {
            return "\(nickname) (\(name))"
        } else {
            return name
        }
    }
    
    func toSentryUser() -> SentryUser {
        let sentryUser = SentryUser(userId: id)
        sentryUser.name = name
        sentryUser.username = nickname
        sentryUser.email = email
        
        return sentryUser
    }
}

extension User : Identifiable {}

extension User : Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension User : Codable {}
