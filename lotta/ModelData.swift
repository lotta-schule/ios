//
//  ModelData.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 19/09/2023.
//

import LottaCoreAPI
import Apollo
import SwiftUI

@Observable final class ModelData {
    private(set) var currentTenant: Tenant? = nil
    private(set) var currentSession: LoginSession? = nil
    private(set) var api = CoreApi()
    
    private(set) var conversations = [Conversation]()
    
    var unreadMessageCount: Int {
        self.conversations.reduce(into: 0) { partialResult, conversation in
            partialResult += conversation.unreadMessages
        }
    }
    
    func setTenant(_ tenant: Tenant) -> Void {
        let shouldUpdateApi = tenant != currentTenant
        self.currentTenant = tenant
        if shouldUpdateApi {
            self.setApi()
        }
    }
    
    func setSession(_ session: LoginSession?) -> Void {
        let shouldUpdateApi = session != currentSession
        self.currentSession = session
        if shouldUpdateApi {
            self.setApi()
        }
    }
    
    func addMessage(_ message: Message, toConversation conversation: Conversation) -> Void {
        let conversationIndex = self.conversations.firstIndex(where: { $0.id == conversation.id })
        if let i = conversationIndex {
            if !self.conversations[i].messages.contains(where: { $0.id == message.id }) {
                self.conversations[i].messages.append(message)
            }
            self.conversations[i].unreadMessages += 1
        } else {
            self.conversations.append(conversation)
            addMessage(message, toConversation: conversation)
        }
    }
    
    func reset(keepCurrentTenantSlug: Bool = false) -> Void {
        if !keepCurrentTenantSlug {
            UserDefaults.standard.set("", forKey: "lotta-tenant-slug")
        }
        self.currentTenant = nil
        self.currentSession = nil
        self.api = CoreApi()
    }
    
    func loadConversations() async throws -> Void {
        let result = try await api.apollo.fetchAsync(query: GetConversationsQuery(), cachePolicy: .fetchIgnoringCacheData)
        if let conversations =
            result.data?.conversations?.filter({ conversation in
                conversation != nil
            }).map({ Conversation(from: $0!) }) {
            self.conversations = conversations.sorted(by: {
                $0.updatedAt.compare($1.updatedAt) == .orderedDescending
            })
        }
    }
    
    func loadConversation(_ conversation: Conversation) async throws -> Void {
        let result = try await api.apollo.fetchAsync(query: GetConversationQuery(id: conversation.id), cachePolicy: .fetchIgnoringCacheData)
        if let conversationData = result.data?.conversation {
            let loadedConversation = Conversation(from: conversationData)
            if let i = self.conversations.firstIndex(where: { $0.id == conversation.id }) {
                self.conversations[i] = loadedConversation
            } else {
                self.conversations.append(loadedConversation)
            }
        }
    }
    
    func subscribeToMessages() -> Void {
        _ = api.apollo.subscribe(
            subscription: ReceiveMessageSubscription()) {
                switch $0 {
                    case .success(let graphqlResult):
                        let conversation = Conversation(from: graphqlResult.data!.message!.conversation!)
                        let message = Message(from: graphqlResult.data!.message!)
                        self.addMessage(message, toConversation: conversation)
                    case .failure(let error):
                        print("Error subscribing: \(error)")
                }
            }
    }

    private func setApi() -> Void {
        if let currentTenant = currentTenant {
            if let currentSession = currentSession, let token = currentSession.token {
                self.api = CoreApi(withTenantSlug: currentTenant.slug, tenantId: currentTenant.id, andAuthToken: token)
            } else {
                self.api = CoreApi(withTenantSlug: currentTenant.slug)
            }
        } else {
            self.api = CoreApi()
        }
    }
}
