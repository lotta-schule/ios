//
//  ModelData.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 19/09/2023.
//

import KeychainSwift
import LottaCoreAPI
import JWTDecode
import SwiftUI
import Apollo

let keychain = KeychainSwift()

@Observable final class ModelData {
    private(set) var currentTenant: Tenant? = nil
    private(set) var currentSession = LoginSession()
    private(set) var currentUser: User? = nil
    private(set) var api = CoreApi()
    
    private(set) var conversations = [Conversation]()
    
    var unreadMessageCount: Int {
        let count = self.conversations.reduce(into: 0) { partialResult, conversation in
            partialResult += conversation.unreadMessages
        }
        UIApplication.shared.applicationIconBadgeNumber = count
        return count
    }
    
    var theme: Theme {
        self.currentTenant?.customTheme ?? Theme.Default
    }
    
    func setTenant(_ tenant: Tenant) -> Void {
        let shouldUpdateApi = tenant != currentTenant
        self.currentTenant = tenant
        
        if shouldUpdateApi {
            let savedRefreshToken = keychain.get("\(tenant.id)--refresh-token")
            
            if let tokenString = savedRefreshToken, let jwt = try? decode(jwt: tokenString) {
                self.currentSession.refreshToken = jwt
            }
        
            _ = self.recreateApi()
            
            Task {
                await self.authenticate()
            }
        }
    }
    
    func setUser(_ user: User) -> Void {
        self.currentUser = user
        let updatedApi = self.recreateApi()
        PushNotificationService.shared.startReceivingNotifications(api: updatedApi)
    }
    
    func resetUser() -> Void {
        self.currentUser = nil
        self.currentSession.accessToken = nil
        self.currentSession.refreshToken = nil
        Task {
            await PushNotificationService.shared.stopReceivingNotifications()
        }
        _ = self.recreateApi()
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
        self.resetUser()
        self.api = CoreApi()
    }
    
    // API Helper Functions
    
    func authenticate(username: String, password: String) async -> Bool {
        do {
            let tokenGraphqlResult = try await api.apollo.performAsync(
                mutation: LoginMutation(username: username, password: password)
            )
            guard let accessToken = tokenGraphqlResult.data?.login?.accessToken, let accessToken = try? decode(jwt: accessToken) else {
                return false
            }
            currentSession.accessToken = accessToken
            
            _ = self.recreateApi()
            
            return await authenticate()
        } catch {
            print("Error: \(error)")
            return false
        }
    }
    
    func authenticate() async -> Bool {
        do {
            let userGraphqlResult = try await api.apollo.fetchAsync(
                query: GetCurrentUserQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            guard let userResult = userGraphqlResult.data?.currentUser else {
                print("No user in response! \(userGraphqlResult)")
                self.resetUser()
                return false
            }
            self.setUser(User(from: userResult))
            
           await UIApplication.shared.registerForRemoteNotifications()
            return true
        } catch {
            print("error logging in: \(error)")
            return false
        }
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

    private func recreateApi() -> CoreApi {
        if let currentTenant = currentTenant {
            if currentSession.accessToken != nil {
                self.api = CoreApi(withTenantSlug: currentTenant.slug, tenantId: currentTenant.id, andLoginSession: currentSession)
            } else {
                self.api = CoreApi(withTenantSlug: currentTenant.slug, loginSession: currentSession)
            }
        } else {
            self.api = CoreApi()
        }
        
        return self.api
    }
}
