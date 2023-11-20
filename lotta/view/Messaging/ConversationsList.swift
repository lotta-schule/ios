//
//  ConversationsList.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct ConversationsList : View {
    @Environment(UserSession.self) private var userSession
    @Environment(RouterData.self) private var routerData: RouterData
    
    @State private var currentSelectionId: ID? = nil
    
    var withNewMessageDestination: NewMessageDestination?
    
    var body: some View {
        List(userSession.conversations, selection: $currentSelectionId) { conversation in
            ConversationListItem(conversation: conversation, excluding: userSession.user)
        // .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
        .onChange(of: currentSelectionId, initial: true) {
            withAnimation {
                routerData.selectedConversationId = currentSelectionId
            }
        }
        .onChange(of: routerData.selectedConversationId, initial: true) {
            if routerData.selectedConversationId != currentSelectionId {
                withAnimation {
                    currentSelectionId = routerData.selectedConversationId
                }
            }
        }
    }
    
    func getConversations() -> [Conversation] {
        if let newMessageDestination = withNewMessageDestination {
            return [
                newMessageDestination.asConversation(
                    in: userSession.tenant,
                    currentUser: userSession.user
                ),
            ] + userSession.conversations
        } else {
            return userSession.conversations
        }
    }
}
