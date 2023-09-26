//
//  User.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 21/09/2023.
//

import LottaCoreAPI
import SwiftData

@Model
class User: Identifiable {
    @Attribute(.unique) var id: ID
    
    var tenant: Tenant
    
    var name: String?
    
    var nickname: String?
    
    var avatarImageFileId: LottaFileID?
    
    init(id: ID, name: String?, nickname: String?, avatarImageFileId: LottaFileID? = nil, tenant: Tenant) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.avatarImageFileId = avatarImageFileId
        self.tenant = tenant
    }
    
    convenience init(from graphQLResult: GetCurrentUserQuery.Data.CurrentUser, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id,
            tenant: tenant
        )
    }
    
    convenience init(from graphQLResult: GetConversationsQuery.Data.Conversation.User, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id,
            tenant: tenant
        )
    }
    
    convenience init(from graphQLResult: GetConversationQuery.Data.Conversation.User, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id,
            tenant: tenant
        )
    }
    
    convenience init(from graphQLResult: GetConversationQuery.Data.Conversation.Message.User, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id,
            tenant: tenant
        )
    }
    
    convenience init(from graphQLResult: SendMessageMutation.Data.Message.User, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id,
            tenant: tenant
        )
    }
    
    convenience init(from graphQLResult: ReceiveMessageSubscription.Data.Message.User, for tenant: Tenant) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id,
            tenant: tenant
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
