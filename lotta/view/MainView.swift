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
    @Environment(UserSession.self) private var userSession
    @Environment(RouterData.self) private var routerData
    
    @State private var unreadMessagesCount = 0
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
        .onChange(of: unreadMessagesCount, { _, _ in
            Task {
                await ModelData.shared.setApplicationBadgeNumber()
            }
        })
        .onChange(of: scenePhase, initial: true, { _, phase in
            switch scenePhase {
            case .active:
                Task {
                    try? await subscribeToMessages()
                }
            case .background, .inactive:
                maybeUnsubscribeToMessages()
            default:
                print("Unknown phase \(phase)")
            }
        })
        .onAppear {
            Task {
                try? await subscribeToMessages()
            }
            watchUnreadMessagesCount()
        }
        .onDisappear {
            maybeUnsubscribeToMessages()
            mayUnwatchUnreadMessagesCount()
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
                    do {
                        if let conversationId = graphqlResult.data?.message?.conversation?.id {
                            // Add conversation
                            let getConversationsQueryCache = try transaction.read(query: GetConversationsQuery())
                            let addConversationCacheMutation = AddConversationLocalCacheMutation()
                            
                            guard let _conversationFieldData = graphqlResult.data?.message?.conversation?._fieldData else {
                                return
                            }
                            var newConversation = AddConversationLocalCacheMutation.Data.Conversation(
                                _fieldData: _conversationFieldData
                            )
                            newConversation.messages = [
                                AddConversationLocalCacheMutation.Data.Conversation.Message(id: graphqlResult.data?.message?.id)
                            ]
                            
                            try transaction.update(addConversationCacheMutation) { (data: inout AddConversationLocalCacheMutation.Data) in
                                if let i = getConversationsQueryCache.conversations?.firstIndex(where: { $0?.id == conversationId }) {
                                    // when currently looking at the conversation, we do not want to change the counter
                                    if RouterData.shared.selectedConversationId != graphqlResult.data?.message?.conversation?.id {
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
                            
                            guard let _addMessageFieldData = graphqlResult.data?.message?._fieldData else {
                                return
                            }
                            let newMessage = AddMessageToConversationLocalCacheMutation.Data.Conversation.Message(_fieldData: _addMessageFieldData)
                            
                            try transaction.update(addMessageCacheMutation) { (data: inout AddMessageToConversationLocalCacheMutation.Data) in
                                if data.conversation?.messages?.contains(where: { $0.id == newMessage.id }) != true {
                                    data.conversation?.messages?.append(newMessage)
                                }
                            }
                        }
                    } catch {
                        print("Fehler: \(String(describing: error))")
                        throw error
                    }
                }) { _result in
                }
            case .failure(let error):
                SentrySDK.capture(error: error)
                print("Error subscribing: \(error)")
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
                query: GetConversationsQuery(
            )) { result in
                switch result {
                case .success(let graphqlResult):
                    if let conversationsData = graphqlResult.data?.conversations {
                        self.unreadMessagesCount = conversationsData.reduce(0, { partialResult, conversation in
                            partialResult + (conversation?.unreadMessages ?? 0)
                        })
                    }
                case .failure(let error):
                    SentrySDK.capture(error: error)
                    print("ERROR: \(error)")
                }
            }
    }
    
    func mayUnwatchUnreadMessagesCount() -> Void {
        cancelConversationsQueryWatch?.cancel()
        cancelConversationsQueryWatch = nil
    }
}
