//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 26/09/2023.
//

import SwiftUI
import Apollo
import LottaCoreAPI
import Sentry

struct MainView : View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ModelData.self) private var modelData
    @Environment(UserSession.self) private var userSession
    @Environment(RouterData.self) private var routerData
    
    @State private var unreadMessagesCount = 0
    @State private var otherUnreadMessagesCount = 0
    @State private var isSubscribingToMessages = false
    @State private var cancelMessageSubscription: Cancellable?
    @State private var cancelConversationsQueryWatch: Cancellable?
    
    @State private var viewSelection = 0
    
    var body: some View {
        TabView(selection: $viewSelection) {
            MessagingView()
                .badge(unreadMessagesCount)
                .tabItem {
                    Label("Nachrichten", systemImage: "message")
                }
            ProfileView()
                .badge(otherUnreadMessagesCount)
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .tint(userSession.theme.primaryColor)
        .onChange(of: routerData.rootSection, { _, section in
            switch section {
                case .messaging:
                    viewSelection = 0
                case .profile:
                    viewSelection = 1
            }
        })
        .onChange(of: viewSelection) {
            switch viewSelection {
                case 1:
                    routerData.rootSection = .profile
                    return
                default:
                    routerData.rootSection = .messaging
                    return
            }
        }
        .onChange(of: scenePhase, initial: true, { _, phase in
            switch scenePhase {
            case .active:
                Task {
                    try? await subscribeToMessages()
                }
                updateUnreadMessagesCounts()
            case .background, .inactive:
                maybeUnsubscribeToMessages()
            default:
                print("Unknown phase \(phase)")
            }
        })
        .onChange(of: routerData.selectedConversationId) {
            updateUnreadMessagesCounts()
        }
        .onChange(of: modelData.currentSession, initial: true) { _, _ in
            updateUnreadMessagesCounts()
        }
        .onAppear {
            Task {
                try? await subscribeToMessages()
            }
            watchUnreadMessagesCount()
            updateUnreadMessagesCounts()
        }
        .onDisappear {
            maybeUnsubscribeToMessages()
            mayUnwatchUnreadMessagesCount()
        }
    }
    
    func updateUnreadMessagesCounts() -> Void {
        Task {
            unreadMessagesCount = (try? await userSession.getUnreadMessagesCount(skippingConversationId: routerData.selectedConversationId)) ?? 0
            let otherSessions = modelData.userSessions
                .filter { $0.tenant.id != userSession.tenant.id || $0.user.id != userSession.user.id }
            var count = 0
            for session in otherSessions {
                count += (try? await session.getUnreadMessagesCount()) ?? 0
            }
            otherUnreadMessagesCount = count
            
            await ModelData.shared.setApplicationBadgeNumber()
        }
    }
    
    func subscribeToMessages() async throws -> Void {
        if isSubscribingToMessages {
            throw UserSessionError.isAlreadySubscribing
        }
        isSubscribingToMessages = true
        defer {
            isSubscribingToMessages = false
        }
        if userSession.authInfo.needsRenew {
            _ = try await userSession.authInfo.renewAsync()
        }
        maybeUnsubscribeToMessages()
        cancelMessageSubscription = userSession.api.apollo.subscribe(
            subscription: ReceiveMessageSubscription()
        ) { response in
            switch response {
            case .success(let graphqlResult):
                userSession.api.apollo.store.withinReadWriteTransaction({ transaction in
                    guard let data = graphqlResult.data else {
                        return
                    }
                    try self.onReceiveMessageTransaction(transaction: transaction, gqlData: data)
                })
            case .failure(let error):
                SentrySDK.capture(error: error)
                print("Error subscribing: \(error)")
            }
        }
    }
    
    func onReceiveMessageTransaction(transaction: ApolloStore.ReadWriteTransaction, gqlData: ReceiveMessageSubscription.Data) throws -> Void {
        guard let conversationId = gqlData.message?.conversation.id else {
            return
        }
        
        // Add conversation
        let getConversationsQueryCache = try transaction.read(query: GetConversationsQuery())
        let addConversationCacheMutation = AddConversationLocalCacheMutation()
        
        guard let _conversationFieldData = gqlData.message?.conversation._fieldData else {
            return
        }
        var newConversation = AddConversationLocalCacheMutation.Data.Conversation(
            _fieldData: _conversationFieldData
        )
        newConversation.messages = [
            AddConversationLocalCacheMutation.Data.Conversation.Message(id: gqlData.message?.id ?? "")
        ]
        
        try transaction.update(addConversationCacheMutation) { (data: inout AddConversationLocalCacheMutation.Data) in
            if let i = getConversationsQueryCache.conversations?.firstIndex(where: { $0?.id == conversationId }) {
                // when currently looking at the conversation, we do not want to change the counter
                if RouterData.shared.selectedConversationId != gqlData.message?.conversation.id {
                    data.conversations?[i]?.unreadMessages = newConversation.unreadMessages
                }
                data.conversations?[i]?.updatedAt = newConversation.updatedAt
                // data.conversations?[i]?.messages = data.conversations?[i]?.messages?.append(contentsOf: newConversation.messages ?? [])
            } else {
                data.conversations?.append(newConversation)
            }
        }
        
        // Add Message
        let addMessageCacheMutation = AddMessageToConversationLocalCacheMutation(id: conversationId)
        
        guard let _addMessageFieldData = gqlData.message?._fieldData else {
            return
        }
        let newMessage = AddMessageToConversationLocalCacheMutation.Data.Conversation.Message(_fieldData: _addMessageFieldData)
        
        try transaction.update(addMessageCacheMutation) { (data: inout AddMessageToConversationLocalCacheMutation.Data) in
            if data.conversation?.messages?.contains(where: { $0.id == newMessage.id }) != true {
                data.conversation?.messages?.append(newMessage)
            }
        }
    }
    
    func maybeUnsubscribeToMessages() -> Void {
        cancelMessageSubscription?.cancel()
        cancelMessageSubscription = nil
    }
    
    func watchUnreadMessagesCount() -> Void {
        mayUnwatchUnreadMessagesCount()
        cancelConversationsQueryWatch =
            userSession.api.apollo.watch(
                query: GetConversationsQuery()
            ) { result in
                switch result {
                case .success(_):
                    updateUnreadMessagesCounts()
                case .failure(let error):
                    print("ERROR: \(error)")
                }
            }
    }
    
    func mayUnwatchUnreadMessagesCount() -> Void {
        cancelConversationsQueryWatch?.cancel()
        cancelConversationsQueryWatch = nil
    }
}
