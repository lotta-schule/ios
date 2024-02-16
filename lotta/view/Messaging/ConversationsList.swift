//
//  ConversationsList.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Apollo
import SwiftUI
import LottaCoreAPI

struct ConversationsList : View {
    @Environment(UserSession.self) private var userSession
    @Environment(RouterData.self) private var routerData: RouterData
    
    @State private var conversations = [GetConversationsQuery.Data.Conversation]()
    @State private var cancelConversationsQueryWatch: Cancellable?
    @State private var currentSelectionId: ID? = nil
    
    var withNewMessageDestination: NewMessageDestination?
    
    var body: some View {
        List(getConversationsList(), id: \.self.id.unsafelyUnwrapped, selection: $currentSelectionId) { conversation in
            ConversationListItem(conversation: conversation)
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
        .onAppear {
            cancelConversationsQueryWatch?.cancel()
            cancelConversationsQueryWatch = userSession.api.apollo.watch(
                query: GetConversationsQuery()) { result in
                    switch result {
                    case .success(let graphqlResult):
                        if let conversationsData = graphqlResult.data?.conversations {
                            self.conversations = conversationsData.compactMap { $0 } .sorted(by: {
                                let d1 = $0.updatedAt?.toDate() ?? Date()
                                let d2 = $1.updatedAt?.toDate() ?? Date()
                                return d1.compare(d2) == .orderedDescending
                            })
                        }
                    case .failure(let error):
                        // TDOO: Fehlerbehandlung
                        print("ERROR: \(error)")
                    }
                }
        }
    }
    
    func getConversationsList() -> [GetConversationsQuery.Data.Conversation] {
        if let fakeConversation = getFakeConversationFromNewMessageDestination() {
            var result: [GetConversationsQuery.Data.Conversation] = [fakeConversation]
            result.append(contentsOf: self.conversations)
            return result
        }
        return conversations
    }
    
    func getFakeConversationFromNewMessageDestination() -> GetConversationsQuery.Data.Conversation? {
        guard let newMessageDestination = withNewMessageDestination else {
            return nil
        }
        
        var users = [GetConversationsQuery.Data.Conversation.User]()
        var groups = [Group]()
        
        switch newMessageDestination {
        case .user(let user):
            users = [GetConversationsQuery.Data.Conversation.User(_fieldData: user._fieldData)]
        case .group(let group):
            groups = [group]
        }
        
        return try? GetConversationsQuery.Data.Conversation(data: [
            "__typename": "Conversation",
            "id": "-001",
            "updatedAt": Date().ISO8601Format(),
            "unreadMessages": 0,
            "groups": groups,
            "users": users,
            "messages": []
        ])
    }
}
