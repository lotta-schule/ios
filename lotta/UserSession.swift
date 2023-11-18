//
//  UserSession.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 20/10/2023.
//

import UIKit
import Sentry
import Apollo
import JWTDecode
import Foundation
import LottaCoreAPI
import KeychainSwift

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
        return self.conversations.reduce(into: 0) { partialResult, conversation in
            partialResult += conversation.unreadMessages
        }
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
                query: GetCurrentUserQuery()
            )
            guard let userResult = userGraphqlResult.currentUser else {
                // self.resetUser()
                return .error(AuthenticationError.invalidResponse("No user in response! \(userGraphqlResult)"))
            }
            self.user = User(in: tenant, from: userResult)
            
            await UIApplication.shared.registerForRemoteNotifications()
            return .success
        } catch {
            return .error(error)
        }
    }
    
    func refetchTenantData() async -> AuthenticationResult {
        do {
            let tenantGraphqlResult = try await api.apollo.fetchAsync(
                query: GetTenantQuery()
            )
            guard let tenantResult = tenantGraphqlResult.tenant else {
                // self.resetUser()
                return .error(AuthenticationError.invalidResponse("No user in response! \(tenantGraphqlResult)"))
            }
            self.tenant = Tenant(from: tenantResult)
            
            await UIApplication.shared.registerForRemoteNotifications()
            return .success
        } catch {
            return .error(error)
        }
    }
    
    func loadConversations() async throws -> Void {
        let result = try await api.apollo.fetchAsync(query: GetConversationsQuery())
        if let conversations =
            result.conversations?.filter({ conversation in
                conversation != nil
            }).map({ Conversation(in: tenant, from: $0!) }) {
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
        let message = Message(in: tenant, from: messageData)
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
        let message = Message(in: tenant, from: messageData)
        return message
    }
    
    func loadConversation(_ conversation: Conversation) async throws -> Void {
        let result = try await api.apollo.fetchAsync(query: GetConversationQuery(id: conversation.id))
        if let conversationData = result.conversation {
            let loadedConversation = Conversation(in: tenant, from: conversationData)
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
                    let conversation = Conversation(in: self.tenant, from: graphqlResult.data!.message!.conversation!)
                    let message = Message(in: self.tenant, from: graphqlResult.data!.message!)
                    self.addMessage(message, toConversation: conversation)
                case .failure(let error):
                    SentrySDK.capture(error: error)
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
        
        let authInfo = AuthInfo()
        let tenantApi = CoreApi(withTenantSlug: tenant.slug, loginSession: authInfo)
        
        let tokenGraphqlResult = try await tenantApi.apollo.performAsync(
            mutation: LoginMutation(username: username, password: password)
        )
        guard let accessToken = tokenGraphqlResult.data?.login?.accessToken,
              let accessToken = try? decode(jwt: accessToken) else {
            throw AuthenticationError.invalidResponse("No auth token in response!")
        }
        if accessToken.claim(name: "typ").string != "access" {
            throw AuthenticationError.invalidResponse("Auth token is not a valid lotta jwt access token")
        }
        
        guard let userId = accessToken.subject else {
            throw AuthenticationError.invalidResponse("Auth token is not valid, does not contain a user id")
        }
        
        authInfo.accessToken = accessToken
        let user = User(tenant: tenant, id: userId)
        let userSession = UserSession(tenant: tenant, authInfo: authInfo, user: user)
        
        _ = try? await authInfo.renewAsync()
        
        switch await userSession.refetchUserData() {
            case .error(let authError):
                throw authError
            case .success:
                try? userSession.writeToDisk()
                return userSession
        }
    }
    
    static func readFromDisk() -> [UserSession] {
        var results = [UserSession]()
        let keychain = KeychainSwift()
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let sessionFiles = files.filter { url in
                let regex = /^usersession-[^-]+-[^-]+\.json$/
                return url.isFileURL && url.lastPathComponent.wholeMatch(of: regex) != nil
            }
            for fileUrl in sessionFiles {
                if let userSessionData = try? Data(contentsOf: fileUrl),
                   let persistedUserSession = try? JSONDecoder().decode(PersistedUserSession.self, from: userSessionData),
                   let refreshToken = keychain.get("\(persistedUserSession.tenant.id)--refresh-token"),
                   let jwt = try? JWTDecode.decode(jwt: refreshToken),
                   jwt.expired == false {
                    let authInfo = AuthInfo(refreshToken: jwt)
                    let userSession = UserSession(tenant: persistedUserSession.tenant, authInfo: authInfo, user: persistedUserSession.user)
                    
                    results.append(userSession)
                    
                    Task {
                        _ = await userSession.refetchUserData()
                        _ = await userSession.refetchTenantData()
                        try? userSession.writeToDisk()
                    }
                } else {
                    do {
                        try FileManager.default.removeItem(at: fileUrl)
                    } catch {
                        print("error writing usersession data: \(error)")
                    }
                }
            }
        } catch {
            SentrySDK.capture(error: error)
            print("Error reading files: \(error)")
        }
        
        return results
    }
    
    func writeToDisk() throws -> Void {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let fileURL = documentsURL.appendingPathComponent("usersession-\(tenant.id)-\(user.id).json")
        
        let persistedUserSession = PersistedUserSession(tenant: tenant, user: user)
        do {
            try JSONEncoder().encode(persistedUserSession).write(to: fileURL)
        } catch {
            SentrySDK.capture(error: error)
            print("error writing usersession data: \(error)")
        }
    }
    
    func removeFromDisk() throws -> Void {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let fileURL = documentsURL.appendingPathComponent("usersession-\(tenant.id)-\(user.id).json")
        
        try FileManager.default.removeItem(at: fileURL)
    }
}

extension UserSession: Equatable {
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.tenant.id == rhs.tenant.id
    }
}
