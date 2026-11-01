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
    @State private var olderMessages: [GetConversationQuery.Data.Conversation.Message] = []
    @State private var isLoadingOlder = false
    @State private var hasMoreOlder = true

    private let pageSize = 30
    
    var conversationId: ID
    
    var body: some View {
        VStack {
            if let conversation = conversation {
                VStack {
                    MessageList(
                        messages: allMessages(of: conversation),
                        hasMoreOlder: hasMoreOlder && (conversation.messages?.count ?? 0) >= pageSize,
                        isLoadingOlder: isLoadingOlder,
                        onLoadOlder: { Task { await loadOlderMessages() } },
                        isGroupChat: conversation.groups?.isEmpty == false
                    )
                    
                    MessageInputView(
                        userId: conversation.users?.first(where: { $0.id != userSession.user.id })?.id,
                        groupId: conversation.groups?.first?.id
                    )
                }
                .navigationTitle(ConversationUtil.getTitle(for: conversation, excludingUserId: userSession.user.id))
                .toolbar {
                    if let user = conversation.users?.first(where: { $0.id != userSession.user.id }),
                       let urlStr = user.avatarImageFile?.formats.first(where: { format in
                           !(format.url?.isEmpty ?? true)
                       })?.url {
                        ToolbarItem(placement: .topBarTrailing) {
                            Avatar(url: URL(string: urlStr))
                        }
                    }
                }
            }
        }
        .onChange(of: conversationId, initial: true) { _, _ in
            olderMessages = []
            hasMoreOlder = true
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
    
    private func allMessages(of conversation: GetConversationQuery.Data.Conversation) -> [GetConversationQuery.Data.Conversation.Message] {
        let live = conversation.messages ?? []
        let liveIds = Set(live.map { $0.id })
        return olderMessages.filter { !liveIds.contains($0.id) } + live
    }

    private func loadOlderMessages() async {
        guard !isLoadingOlder, hasMoreOlder, let conversation = conversation else { return }
        let known = allMessages(of: conversation)
        guard let oldest = known.min(by: { (Int($0.id) ?? 0) < (Int($1.id) ?? 0) }) else { return }
        isLoadingOlder = true
        defer { isLoadingOlder = false }
        do {
            let result = try await userSession.api.apollo.fetchAsync(
                query: GetConversationMessagesQuery(id: conversationId, before: .some(oldest.id), first: .some(pageSize)),
                cachePolicy: .fetchIgnoringCacheData
            )
            let fetched = result.conversation?.messages ?? []
            olderMessages += fetched.map { GetConversationQuery.Data.Conversation.Message(_dataDict: $0.__data) }
            hasMoreOlder = fetched.count >= pageSize
        } catch {
            print("ERROR loading older messages: \(error)")
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
