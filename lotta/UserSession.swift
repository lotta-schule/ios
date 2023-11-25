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

enum UserSessionError : Error {
    case generic(String)
    case isAlreadySubscribing
}

@Observable class UserSession {
    private(set) var tenant: Tenant
    private(set) var authInfo: AuthInfo
    private(set) var user: User
    private(set) var api: CoreApi
    private(set) var conversations = [Conversation]()
    private(set) var deviceId: ID?
    
    init(tenant: Tenant, authInfo: AuthInfo, user: User) { // TODO: Could default to create user from authToken.accessToken
        self.tenant = tenant
        self.authInfo = authInfo
        self.user = user
        self.api = CoreApi(withTenantSlug: tenant.slug, tenantId: tenant.id, andLoginSession: authInfo)
        self.conversations = conversations
    }
    
    var unreadMessageCount: Int {
        return self.conversations.reduce(into: 0) { partialResult, conversation in
            partialResult += conversation.unreadMessages ?? 0
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
            if let unreadMessages = conversation.unreadMessages {
                self.conversations[i].unreadMessages = unreadMessages
            }
            self.conversations[i].updatedAt = conversation.updatedAt
            
            api.apollo.store.withinReadWriteTransaction { transaction in
                
            }
            
        } else {
            self.conversations.insert(conversation, at: 0)
            addMessage(message, toConversation: conversation)
        }
    }
    
    // API Helper Functions
    
    func refetchUserData() async -> AuthenticationResult {
        do {
            let userGraphqlResult = try await api.apollo.fetchAsync(
                query: GetCurrentUserQuery(),
                cachePolicy: .fetchIgnoringCacheData
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
    
    func loadConversations() -> Void {
        api.apollo.fetch(
            query: GetConversationsQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ) { result in
            switch result {
                case .success(let graphqlResult):
                    if let conversations =
                        graphqlResult.data?.conversations?.filter({ conversation in
                            conversation != nil
                        }).map({ Conversation(in: self.tenant, from: $0!) }) {
                        self.conversations = conversations.sorted(by: {
                            $0.updatedAt.compare($1.updatedAt) == .orderedDescending
                        })
                    }
                    if graphqlResult.source == .server {
                        ModelData.shared.setApplicationBadgeNumber()
                    }
                    
                case .failure(let error):
                    print(error)
            }
        }
    }
    func forceLoadConversations() async throws -> Void {
        let result = try await api.apollo.fetchAsync(
            query: GetConversationsQuery(),
            cachePolicy: .fetchIgnoringCacheData
        )
        if let conversations =
            result.conversations?.filter({ conversation in
                conversation != nil
            }).map({ Conversation(in: tenant, from: $0!) }) {
            self.conversations = conversations.sorted(by: {
                $0.updatedAt.compare($1.updatedAt) == .orderedDescending
            })
        }
        ModelData.shared.setApplicationBadgeNumber()
    }
    
    func sendMessage(_ content: String, to user: User) async throws -> (Message, Conversation) {
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
        guard let conversationData = graphqlResult.data?.message?.conversation else {
            throw UserSessionError.generic("Invalid conversation")
        }
        let message = Message(in: tenant, from: messageData)
        let conversation =
            conversations.first(where: { $0.id == conversationData.id }) ??
            Conversation(
                in: tenant,
                from: conversationData,
                withUsers: [user, self.user],
                andGroups: []
            )
        if !conversations.contains(where: { $0.id == conversation.id }) {
            conversations.append(conversation)
        }
        return (message, conversation)
    }
    
    func sendMessage(_ content: String, to group: Group) async throws -> (Message, Conversation) {
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
        guard let conversationData = graphqlResult.data?.message?.conversation else {
            throw UserSessionError.generic("Invalid conversation")
        }
        let message = Message(in: tenant, from: messageData)
        let conversation =
            conversations.first(where: { $0.id == conversationData.id }) ??
            Conversation(
                in: tenant,
                from: conversationData,
                withUsers: [],
                andGroups: [group]
            )
        if !conversations.contains(where: { $0.id == conversation.id }) {
            conversations.append(conversation)
        }
        return (message, conversation)
    }
    
    func loadConversation(_ conversation: Conversation) async throws -> Void {
        let result = try await api.apollo.fetchAsync(query: GetConversationQuery(id: conversation.id))
        if let conversationData = result.conversation {
            let loadedConversation = Conversation(in: tenant, from: conversationData)
            addConversation(loadedConversation)
        }
    }
    
    func addConversation(_ conversation: Conversation) -> Void {
        if let i = self.conversations.firstIndex(where: { $0.id == conversation.id }) {
            self.conversations[i] = conversation
        } else {
            self.conversations.append(conversation)
        }
        self.conversations = conversations.sorted(by: {
            $0.updatedAt.compare($1.updatedAt) == .orderedDescending
        })
        ModelData.shared.setApplicationBadgeNumber()
    }
    
    var isSubscribingToMessages = false
    var cancelMessageSubscription: Cancellable?
    func subscribeToMessages() async throws -> Void {
        if isSubscribingToMessages {
            throw UserSessionError.isAlreadySubscribing
        }
        isSubscribingToMessages = true
        defer {
            isSubscribingToMessages = false
        }
        if authInfo.needsRenew {
            _ = try await authInfo.renewAsync()
        }
        cancelMessageSubscription = api.apollo.subscribe(
            subscription: ReceiveMessageSubscription()
        ) { response in
            switch response {
            case .success(let graphqlResult):
                let conversation = Conversation(in: self.tenant, from: graphqlResult.data!.message!.conversation!)
                let message = Message(in: self.tenant, from: graphqlResult.data!.message!)
                self.addMessage(message, toConversation: conversation)
                ModelData.shared.setApplicationBadgeNumber()
            case .failure(let error):
                SentrySDK.capture(error: error)
                print("Error subscribing: \(error)")
            }
        }
    }
    
    func unsubscribeToMessages() -> Void {
        cancelMessageSubscription?.cancel()
    }
    
    func registerDevice(token: Data) async throws -> Void {
        let graphqlResult = try await api.apollo.performAsync(
            mutation: RegisterDeviceMutation(
                device: RegisterDeviceInput(
                    deviceType: GraphQLNullable(stringLiteral: DeviceIdentificationService.shared.deviceType),
                    modelName: GraphQLNullable(stringLiteral: DeviceIdentificationService.shared.modelName),
                    operatingSystem: GraphQLNullable(stringLiteral: DeviceIdentificationService.shared.operatingSystem),
                    platformId: "ios/\(DeviceIdentificationService.shared.uniquePlatformIdentifier ?? "0")",
                    pushToken: GraphQLNullable(stringLiteral: "apns/\(token.hexEncodedString)")
                )
            )
        )
        
        deviceId = graphqlResult.data?.device?.id
    }
    
    func deleteDevice() async throws -> Void {
        if let deviceId = deviceId {
            let graphqlResult = try await api.apollo.performAsync(
                mutation: DeleteDeviceMutation(
                    id: deviceId
                )
            )
            
            if graphqlResult.data?.device?.id == deviceId {
                self.deviceId = nil
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
    
    static func readFromDisk() async -> [UserSession] {
        var results = [UserSession]()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: baseCacheDirURL, includingPropertiesForKeys: nil)
            let sessionFiles = files.compactMap { url in
                let regex = /^usersession-([^-]+)-([^-]+)\.json$/
                guard url.isFileURL else {
                    return nil as (URL, Substring, Substring)?
                }
                guard let matches = url.lastPathComponent.wholeMatch(of: regex) else {
                    return nil as (URL, Substring, Substring)?
                }
                return (url, matches.1, matches.2) as (URL, Substring, Substring)
            }
            for (fileUrl, tid, uid) in sessionFiles {
                if let userSessionData = try? Data(contentsOf: fileUrl),
                   let persistedUserSession = try? JSONDecoder().decode(PersistedUserSession.self, from: userSessionData),
                   let refreshToken = keychain.get("\(persistedUserSession.tenant.id)-\(persistedUserSession.user.id)--refresh-token"),
                   let jwt = try? JWTDecode.decode(jwt: refreshToken),
                   jwt.expired == false {
                    let authInfo = AuthInfo(refreshToken: jwt)
                    _ = try? await authInfo.renewAsync()
                    
                    let userSession = UserSession(tenant: persistedUserSession.tenant, authInfo: authInfo, user: persistedUserSession.user)
                    
                    results.append(userSession)
                    
                    _ = await userSession.refetchUserData()
                    _ = await userSession.refetchTenantData()
                    try? userSession.writeToDisk()
                } else {
                    do {
                        keychain.delete("\(tid)-\(uid)--refresh-token")
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
        let fileURL = baseCacheDirURL.appendingPathComponent("usersession-\(tenant.id)-\(user.id).json")
        
        let persistedUserSession = PersistedUserSession(tenant: tenant, user: user)
        do {
            try JSONEncoder().encode(persistedUserSession).write(to: fileURL)
        } catch {
            SentrySDK.capture(error: error)
            print("error writing usersession data: \(error)")
        }
    }
    
    func removeFromDisk() throws -> Void {
        let fileURL = baseCacheDirURL.appendingPathComponent("usersession-\(tenant.id)-\(user.id).json")
        
        try FileManager.default.removeItem(at: fileURL)
    }
    
    func removeFromKeychain() -> Void {
        keychain.delete("usersession-\(tenant.id)-\(user.id).json")
    }
    
}

extension UserSession: Equatable {
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.tenant.id == rhs.tenant.id
    }
}
