//
//  UserUtil.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 25/11/2023.
//

import LottaCoreAPI

struct UserUtil {
    private init() {}

    static func getVisibleName(for user: GetConversationQuery.Data.Conversation.Message.User) -> String {
        guard let name = user.name, !name.isEmpty else {
            return user.nickname ?? "?"
        }
        if let nickname = user.nickname, !nickname.isEmpty {
            return "\(nickname) (\(name))"
        } else {
            return name
        }
    }
    
    static func getVisibleName(for user: GetConversationQuery.Data.Conversation.User) -> String {
        guard let name = user.name, !name.isEmpty else {
            return user.nickname ?? "?"
        }
        if let nickname = user.nickname, !nickname.isEmpty {
            return "\(nickname) (\(name))"
        } else {
            return name
        }
    }
    
    static func getVisibleName(for user: GetConversationsQuery.Data.Conversation.User) -> String {
        guard let name = user.name, !name.isEmpty else {
            return user.nickname ?? "?"
        }
        if let nickname = user.nickname, !nickname.isEmpty {
            return "\(nickname) (\(name))"
        } else {
            return name
        }
    }
    
    static func getVisibleName(for user: SearchUsersQuery.Data.User) -> String {
        guard let name = user.name, !name.isEmpty else {
            return user.nickname ?? "?"
        }
        if let nickname = user.nickname, !nickname.isEmpty {
            return "\(nickname) (\(name))"
        } else {
            return name
        }
    }
    
}
