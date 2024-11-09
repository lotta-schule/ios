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

@MainActor @Observable class UserSession {
    private(set) var tenant: Tenant
    private(set) var authInfo: AuthInfo
    private(set) var user: User
    private(set) var api: CoreApi
    private(set) var deviceId: ID?
    
    init(tenant: Tenant, authInfo: AuthInfo, user: User) { // TODO: Could default to create user from authToken.accessToken
        self.tenant = tenant
        self.authInfo = authInfo
        self.user = user
        self.api = CoreApi(withTenantSlug: tenant.slug, tenantId: tenant.id, andLoginSession: authInfo)
    }
    
    var theme: Theme {
        self.tenant.customTheme
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
            
            UIApplication.shared.registerForRemoteNotifications()
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
                return .error(AuthenticationError.invalidResponse("No tenant in response! \(tenantGraphqlResult)"))
            }
            self.tenant = Tenant(from: tenantResult)
            
            UIApplication.shared.registerForRemoteNotifications()
            return .success
        } catch {
            return .error(error)
        }
    }
    
    func loadConversations(clearCache: Bool = false, force: Bool = false) async throws -> Void {
        if clearCache {
            try? await api.apollo.clearCacheAsync()
        }
        let _ = try await api.apollo.fetchAsync(
            query: GetConversationsQuery(),
            cachePolicy: force ? .fetchIgnoringCacheData : .returnCacheDataAndFetch
        )
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
            ), queue: .global(qos: .background)
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
    
    func getUnreadMessagesCount(skippingConversationId: ID? = nil) async throws -> Int {
        let data = try await api.apollo.loadAsync(operation: GetConversationsQuery()).data
        return data?.conversations?.reduce(0, { partialResult, conversation in
            if let skippingConversationId = skippingConversationId, conversation?.id == skippingConversationId {
                return partialResult
            }
            return partialResult + (conversation?.unreadMessages ?? 0)
        }) ?? 0
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
        
        func onSessionInitError(session: (fileUrl: URL, tid: String, uid: String)) -> Void {
            let removeItemCrumb = Breadcrumb(level: .info, category: "UserSession")
            removeItemCrumb.message = "Deleting stale user session. Something went wrong when reading the user session data."
            removeItemCrumb.data = ["fileUrl": session.fileUrl.absoluteString, "tid": session.tid, "uid": session.uid]
            SentrySDK.capture(message: "Deleting stale user session. Something went wrong when reading the user session data.")
            do {
                keychain.delete("\(session.tid)-\(session.uid)--refresh-token")
                try FileManager.default.removeItem(at: session.fileUrl)
            } catch {
                SentrySDK.capture(error: error)
                print("error writing usersession data: \(error)")
            }
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: baseCacheDirURL, includingPropertiesForKeys: nil)
            let filesCrumb = Breadcrumb(level: .info, category: "UserSession#init")
            filesCrumb.message = "Read from baseCacheDirURL: \(baseCacheDirURL.path)"
            filesCrumb.data = ["files": files]
            SentrySDK.addBreadcrumb(filesCrumb)
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
            let sessionFilesCrumb = Breadcrumb(level: .info, category: "UserSession#init")
            sessionFilesCrumb.message = "relevant sessionFiles have been filtered"
            sessionFilesCrumb.data = ["files": sessionFiles]
            SentrySDK.addBreadcrumb(sessionFilesCrumb)
            for (fileUrl, tid, uid) in sessionFiles {
                guard let userSessionData = try? Data(contentsOf: fileUrl) else {
                    let crumb = Breadcrumb(level: .info, category: "UserSession#init")
                    crumb.message = "the fileUrl could not be read. Skipping ..."
                    crumb.data = ["fileUrl": fileUrl.absoluteString, "tid": tid, "uid": uid]
                    SentrySDK.addBreadcrumb(crumb)
                    onSessionInitError(session: (fileUrl, String(tid), String(uid)))
                    continue
                }
                guard let persistedUserSession = try? JSONDecoder().decode(PersistedUserSession.self, from: userSessionData) else {
                    let crumb = Breadcrumb(level: .info, category: "UserSession#init")
                    crumb.message = "the userSessionData could not be decoded. Skipping ..."
                    crumb.data = ["fileUrl": fileUrl.absoluteString, "tid": tid, "uid": uid, "userSessionData": userSessionData]
                    SentrySDK.addBreadcrumb(crumb)
                    onSessionInitError(session: (fileUrl, String(tid), String(uid)))
                    continue
                }
                guard let refreshToken = keychain.get("\(persistedUserSession.tenant.id)-\(persistedUserSession.user.id)--refresh-token") else {
                    let crumb = Breadcrumb(level: .info, category: "UserSession#init")
                    crumb.message = "Refreshtoken could not be retrieved from Keychain. Skipping .."
                    crumb.data = ["fileUrl": fileUrl.absoluteString, "tid": tid, "uid": uid, "userSessionData": userSessionData, "keychainKey": "\(persistedUserSession.tenant.id)-\(persistedUserSession.user.id)--refresh-token"]
                    SentrySDK.addBreadcrumb(crumb)
                    onSessionInitError(session: (fileUrl, String(tid), String(uid)))
                    continue
                }
                guard let jwt = try? JWTDecode.decode(jwt: refreshToken) else {
                    let crumb = Breadcrumb(level: .info, category: "UserSession#init")
                    crumb.message = "JWT could not be decoded. Skipping ..."
                    crumb.data = ["fileUrl": fileUrl.absoluteString, "tid": tid, "uid": uid, "userSessionData": userSessionData, "keychainKey": "\(persistedUserSession.tenant.id)-\(persistedUserSession.user.id)--refresh-token", "jwt": refreshToken]
                    SentrySDK.addBreadcrumb(crumb)
                    onSessionInitError(session: (fileUrl, String(tid), String(uid)))
                    continue
                }
                guard jwt.expired == false else {
                    let crumb = Breadcrumb(level: .info, category: "UserSession#init")
                    crumb.message = "JWT is expired. Skipping ..."
                    crumb.data = ["fileUrl": fileUrl.absoluteString, "tid": tid, "uid": uid, "userSessionData": userSessionData, "keychainKey": "\(persistedUserSession.tenant.id)-\(persistedUserSession.user.id)--refresh-token", "jwt": refreshToken]
                    SentrySDK.addBreadcrumb(crumb)
                    onSessionInitError(session: (fileUrl, String(tid), String(uid)))
                    continue
                }
                
                let authInfo = AuthInfo(refreshToken: jwt)
                _ = try? await authInfo.renewAsync()
                
                let userSession = UserSession(tenant: persistedUserSession.tenant, authInfo: authInfo, user: persistedUserSession.user)
                
                results.append(userSession)
                let appendedCrumb = Breadcrumb(level: .info, category: "UserSession#init")
                appendedCrumb.message = "UserSession initialized successfully."
                appendedCrumb.data = ["userSession": userSession]
                SentrySDK.addBreadcrumb(appendedCrumb)

                Task {
                    _ = await userSession.refetchUserData()
                    _ = await userSession.refetchTenantData()
                    try? userSession.writeToDisk()
                }

            }
        } catch {
            print("Error reading files: \(error)")
            SentrySDK.capture(error: error)
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
