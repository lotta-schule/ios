//
//  UserSession.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 20/10/2023.
//

import Foundation
import JWTDecode
import LottaCoreAPI
import UIKit
import Apollo

enum UserSessionError : Error {
    case generic(String)
}

@Observable class UserSession {
    private(set) var tenant: Tenant
    private(set) var authInfo: AuthInfo
    private(set) var user: User
    private(set) var api: CoreApi
    private(set) var conversations = [Conversation]()
    
    init(tenant: Tenant, authInfo: AuthInfo, user: User) { // TODO: Could default to create user from authToken.accessToken
        self.tenant = tenant
        self.authInfo = authInfo
        self.user = user
        self.api = CoreApi(withTenantSlug: tenant.slug, tenantId: tenant.id, andLoginSession: authInfo)
        self.conversations = conversations
    }
    
    var unreadMessageCount: Int {
        let count = self.conversations.reduce(into: 0) { partialResult, conversation in
            partialResult += conversation.unreadMessages
        }
        // TODO:
        // UIApplication.shared.applicationIconBadgeNumber = count
        return count
    }
    
    var theme: Theme {
        self.tenant.customTheme
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
        // TODO:
        // self.resetUser()
        self.api = CoreApi()
    }
    
    // API Helper Functions
    
    func refetchUserData() async -> AuthenticationResult {
        do {
            let userGraphqlResult = try await api.apollo.fetchAsync(
                query: GetCurrentUserQuery(),
                queue: .init(label: "test")
            )
            guard let userResult = userGraphqlResult.currentUser else {
                // self.resetUser()
                return .error(AuthenticationError.invalidResponse("No user in response! \(userGraphqlResult)"))
            }
            self.user = User(from: userResult)
            
            await UIApplication.shared.registerForRemoteNotifications()
            return .success
        } catch {
            return .error(error)
        }
    }
    
    func loadConversations() async throws -> Void {
        let result = try await api.apollo.fetchAsync(query: GetConversationsQuery(), cachePolicy: .fetchIgnoringCacheData)
        if let conversations =
            result.conversations?.filter({ conversation in
                conversation != nil
            }).map({ Conversation(from: $0!) }) {
            self.conversations = conversations.sorted(by: {
                $0.updatedAt.compare($1.updatedAt) == .orderedDescending
            })
        }
    }
    
    func sendMessage(_ content: String, to user: User) async throws -> Message {
            let graphqlResult = try await api.apollo.performAsync(
                mutation: SendMessageMutation(
                    message: LottaCoreAPI.MessageInput(
                        content: GraphQLNullable(stringLiteral: content),
                        recipientGroup: nil,
                        recipientUser: GraphQLNullable(SelectUserInput(id: GraphQLNullable(stringLiteral: user.id)))
                    )
                )
            )
        guard let messageData = graphqlResult.data?.message else {
            throw UserSessionError.generic("Invalid Message")
        }
        let message = Message(from: messageData)
        return message
    }
    
    func sendMessage(_ content: String, to group: Group) async throws -> Message {
            let graphqlResult = try await api.apollo.performAsync(
                mutation: SendMessageMutation(
                    message: LottaCoreAPI.MessageInput(
                        content: GraphQLNullable(stringLiteral: content),
                        recipientGroup: GraphQLNullable(SelectUserGroupInput(id: GraphQLNullable(stringLiteral: group.id))),
                        recipientUser: nil
                    )
                )
            )
        guard let messageData = graphqlResult.data?.message else {
            throw UserSessionError.generic("Invalid Message")
        }
        let message = Message(from: messageData)
        return message
    }
    
    func loadConversation(_ conversation: Conversation) async throws -> Void {
        let result = try await api.apollo.fetchAsync(query: GetConversationQuery(id: conversation.id), cachePolicy: .fetchIgnoringCacheData)
        if let conversationData = result.conversation {
            let loadedConversation = Conversation(from: conversationData)
            if let i = self.conversations.firstIndex(where: { $0.id == conversation.id }) {
                self.conversations[i] = loadedConversation
            } else {
                self.conversations.append(loadedConversation)
            }
        }
    }
    
    func subscribeToMessages() -> Cancellable {
        return api.apollo.subscribe(
            subscription: ReceiveMessageSubscription()
        ) {
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
    
    static func createFromCredentials(onTenantSlug slug: String, withUsername username: String, andPassword password: String) async throws -> UserSession {
        let genericApi = CoreApi(withTenantSlug: slug)
        let tenantGraphqlResponse = try await genericApi.apollo.fetchAsync(query: GetTenantQuery())
        guard let tenantData = tenantGraphqlResponse.tenant else {
            throw AuthenticationError.invalidResponse("No tenant found in repsonse \(tenantGraphqlResponse)")
        }
        let tenant = Tenant(from: tenantData)
        
        let tenantApi = CoreApi(withTenantSlug: tenant.slug)
        
        let tokenGraphqlResult = try await tenantApi.apollo.performAsync(
            mutation: LoginMutation(username: username, password: password)
        )
        guard let accessToken = tokenGraphqlResult.data?.login?.accessToken,
              let accessToken = try? decode(jwt: accessToken) else {
            throw AuthenticationError.invalidResponse("No auth token in response!")
        }
        let authInfo = AuthInfo(accessToken: accessToken)
        if accessToken.claim(name: "typ").string != "access" {
            throw AuthenticationError.invalidResponse("Auth token is not a valid lotta jwt access token")
        }
        
        guard let userId = accessToken.subject else {
            throw AuthenticationError.invalidResponse("Auth token is not valid, does not contain a user id")
        }
        
        let user = User(id: userId)
        let userSession = UserSession(tenant: tenant, authInfo: authInfo, user: user)
        
        switch await userSession.refetchUserData() {
            case .error(let authError):
                throw authError
            case .success:
                return userSession
        }
    }
    
}

extension UserSession: Equatable {
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.tenant.id == rhs.tenant.id
    }
}
