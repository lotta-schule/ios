//
//  MessageListView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Apollo
import SwiftUI
import LottaCoreAPI

struct ConversationView : View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    @State private var cancelConversationQueryWatch: Cancellable?
    @State private var conversation: GetConversationQuery.Data.Conversation?
    
    var conversationId: ID
    
    var body: some View {
        VStack {
            if let conversation = conversation {
                VStack {
                    MessageList(messages: conversation.messages ?? [])
                    
                    MessageInputView(
                        userId: conversation.users?.first(where: { $0.id != userSession.user.id })?.id,
                        groupId: conversation.groups?.first?.id
                    )
                }
                .navigationTitle(ConversationUtil.getTitle(for: conversation, excludingUserId: userSession.user.id))
            }
        }
        .onChange(of: conversationId, initial: true) { _, _ in
            watchConversationQuery(id: conversationId)
        }
        .onDisappear {
            unwatchConversationQuery()
        }
    }
    
    func watchConversationQuery(id: ID) -> Void {
        cancelConversationQueryWatch?.cancel()
        cancelConversationQueryWatch = userSession.api.apollo.watch(
            query: GetConversationQuery(id: id, markAsRead: true)
        ) { result in
                switch result {
                case .success(let graphqlResult):
                    if let conversationData = graphqlResult.data?.conversation {
                        self.conversation = conversationData
                    }
                case .failure(let error):
                    // TDOO: Fehlerbehandlung
                    print("ERROR: \(error)")
                }
            }
    }
    
    func unwatchConversationQuery() -> Void {
        cancelConversationQueryWatch?.cancel()
    }
}
