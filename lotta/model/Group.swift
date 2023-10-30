//
//  Group.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import LottaCoreAPI

class Group {
    var id: ID
    
    var name: String
    
    init(id: ID, name: String) {
        self.id = id
        self.name = name
    }
    
    convenience init(from graphqlGroupResult: GetConversationsQuery.Data.Conversation.Group) {
        self.init(
            id: graphqlGroupResult.id!,
            name: graphqlGroupResult.name!
        )
    }
    
    convenience init(from graphqlGroupResult: GetConversationQuery.Data.Conversation.Group) {
        self.init(
            id: graphqlGroupResult.id!,
            name: graphqlGroupResult.name!
        )
    }
    
    convenience init(from graphQLResult: ReceiveMessageSubscription.Data.Message.Conversation.Group) {
        self.init(
            id: graphQLResult.id!,
            name: graphQLResult.name!
        )
    }
}

extension Group: Identifiable {}

extension Group: Hashable {
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
