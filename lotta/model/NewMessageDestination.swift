//
//  NewMessageDestination.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/11/2023.
//

import Foundation

enum NewMessageDestination {
    case user(User)
    case group(Group)
    
    func asConversation(in tenant: Tenant, currentUser: User) -> Conversation {
        var users = [User]()
        var groups = [Group]()
        switch self {
            case .user(let user):
                users = [currentUser, user]
            case .group(let group):
                groups = [group]
        }
        
        return Conversation(
            tenant: tenant,
            id: "",
            users: users,
            groups: groups,
            messages: [],
            updatedAt: Date()
        )
    }
}

extension NewMessageDestination : Equatable {}
