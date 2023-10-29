//
//  User.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 21/09/2023.
//

import LottaCoreAPI
import SwiftData

class User: Identifiable {
    var id: ID
    
    var name: String?
    
    var nickname: String?
    
    var avatarImageFileId: LottaFileID?
    
    init(id: ID, name: String? = nil, nickname: String? = nil, avatarImageFileId: LottaFileID? = nil) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.avatarImageFileId = avatarImageFileId
    }
    
    convenience init(from graphQLResult: GetCurrentUserQuery.Data.CurrentUser) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(from graphQLResult: GetConversationsQuery.Data.Conversation.User) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(from graphQLResult: GetConversationQuery.Data.Conversation.User) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(from graphQLResult: GetConversationQuery.Data.Conversation.Message.User) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(from graphQLResult: SendMessageMutation.Data.Message.User) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(from graphQLResult: ReceiveMessageSubscription.Data.Message.User) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name,
            nickname: graphQLResult.nickname,
            avatarImageFileId: graphQLResult.avatarImageFile?.id
        )
    }
    
    convenience init(from graphQLResult: ReceiveMessageSubscription.Data.Message.Conversation.User) {
        self.init(
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
