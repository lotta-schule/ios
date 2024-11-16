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
                    MessageList(
                        messages: conversation.messages ?? [],
                        isGroupChat: conversation.groups?.isEmpty == false
                    )
                    
                    MessageInputView(
                        userId: conversation.users?.first(where: { $0.id != userSession.user.id })?.id,
                        groupId: conversation.groups?.first?.id
                    )
                }
                .navigationTitle(ConversationUtil.getTitle(for: conversation, excludingUserId: userSession.user.id))
                .toolbar {
                    if let user = conversation.users?.first(where: { $0.id != userSession.user.id }) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Avatar(url: user.avatarImageFile?.id?.getUrl(for: userSession.user.tenant))
                        }
                    }
                }
            }
        }
        .onChange(of: conversationId, initial: true) { _, _ in
            Task {
                let _ = try? await userSession.api.apollo.fetchAsync(query: GetConversationQuery(id: conversationId, markAsRead: true), cachePolicy: .returnCacheDataAndFetch)
                await PushNotificationService.shared.removeNotificationsFor(conversationId: conversationId)
            }
            watchConversationQuery(id: conversationId)
        }
        .onDisappear {
            mayUnwatchConversationQuery()
        }
    }
    
    func watchConversationQuery(id: ID) -> Void {
        mayUnwatchConversationQuery()
        cancelConversationQueryWatch = userSession.api.apollo.watch(
            query: GetConversationQuery(id: id, markAsRead: true),
            cachePolicy: .returnCacheDataAndFetch
        ) { result in
                switch result {
                case .success(let graphqlResult):
                    if let conversationData = graphqlResult.data?.conversation {
                        self.conversation = conversationData
                        userSession.api.apollo.store.withinReadWriteTransaction { transaction in
                            // add / update the conversation to the conversations list
                            let getConversationsQueryCache = try transaction.read(query: GetConversationsQuery())
                            let addConversationCacheMutation = AddConversationLocalCacheMutation()
                            
                            try transaction.update(addConversationCacheMutation) { (data: inout AddConversationLocalCacheMutation.Data) in
                                let newConversation = AddConversationLocalCacheMutation.Data.Conversation(
                                    _fieldData: conversationData._fieldData
                                )
                                if let i = getConversationsQueryCache.conversations?.firstIndex(where: { $0?.id == conversationId }) {
                                    // conversation already is in our cache. Just update with the new message
                                    data.conversations?[i]?.updatedAt = newConversation.updatedAt
                                    data.conversations?[i]?.unreadMessages = newConversation.unreadMessages
                                } else {
                                    // conversation is new, add it to the cache
                                    data.conversations?.append(newConversation)
                                    // newConversation.messages = [AddConversationLocalCacheMutation.Data.Conversation.Message(id: messageId)]
                                }
                            }
                            Task {
                                await ModelData.shared.setApplicationBadgeNumber()
                            }
                            
                        }
                    }
                case .failure(let error):
                    print("ERROR: \(error)")
                }
            }
    }
    
    func mayUnwatchConversationQuery() -> Void {
        cancelConversationQueryWatch?.cancel()
        cancelConversationQueryWatch = nil
    }
}
