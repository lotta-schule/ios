//
//  NewConversationView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/11/2023.
//

import SwiftUI

struct NewConversationView : View {
    @Environment(UserSession.self) private var userSession
    @Environment(RouterData.self) private var routerData
    
    var destination: NewMessageDestination
    
    var body: some View {
        VStack {
            Spacer()
            Text(getDescription())
            Spacer()
            
            MessageInput(
                user: getUser(),
                group: getGroup()
            ) { (message, conversation) in
                withAnimation(.bouncy) {
                    self.routerData.selectedConversationId = conversation.id
                    userSession.addMessage(message, toConversation: conversation)
                }
            }
        }
        .navigationTitle(getUser()?.visibleName ?? getGroup()?.name ?? "")
    }
    
    func getDescription() -> String {
        switch destination {
            case .user(let user):
                return "Neue Unterhaltung mit \(user.visibleName)"
            case .group(let group):
                return "Neue Unterhaltung in \(group.name)"
        }
    }
        
    func getUser() -> User? {
        switch destination {
            case .user(let user):
                return user
            default:
                return nil
        }
    }
    
    func getGroup() -> Group? {
        switch destination {
            case .group(let group):
                return group
            default:
                return nil
        }
    }
}
