//
//  User.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 21/09/2023.
//

import LottaCoreAPI
import SwiftData

final class User {
    var tenant: Tenant
    
    var id: ID
    
    var name: String?
    
    var nickname: String?
    
    var avatarImageFileId: LottaFileID?
    
    init(tenant: Tenant, id: ID, name: String? = nil, nickname: String? = nil, avatarImageFileId: LottaFileID? = nil) {
        self.tenant = tenant
        self.id = id
        self.name = name
        self.nickname = nickname
        self.avatarImageFileId = avatarImageFileId
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetCurrentUserQuery.Data.CurrentUser) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationsQuery.Data.Conversation.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationQuery.Data.Conversation.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: GetConversationQuery.Data.Conversation.Message.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: SendMessageMutation.Data.Message.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: ReceiveMessageSubscription.Data.Message.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(in tenant: Tenant, from graphQLResult: ReceiveMessageSubscription.Data.Message.Conversation.User) {
        self.init(
            tenant: tenant,
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
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
}

extension User: Identifiable {}

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
