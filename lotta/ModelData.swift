//
//  ModelData.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 19/09/2023.
//

import Sentry
import Apollo
import SwiftUI
import JWTDecode
import LottaCoreAPI
import Combine

enum AuthenticationResult {
    case success
    case error(Error)
}

enum AuthenticationError: Error {
    case invalidResponse(String)
}

@MainActor @Observable final class ModelData {
    static let shared = ModelData()
    
    var userSessions = [UserSession]()
    
    private(set) var initialized = false
    
    private var currentSessionTenantId: ID?
    
    func ensureInitialized() async -> Void {
        if !self.initialized {
            await initializeSessions()
        }
    }
    
    func initializeSessions() async -> Void {
        if !FileManager.default.fileExists(atPath: baseCacheDirURL.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: baseCacheDirURL, withIntermediateDirectories: true)
            } catch {
                print("Error creating directory: \(error)")
                SentrySDK.capture(error: error)
            }
        }
        let userSessions = await UserSession.readFromDisk()
        if userSessions.isEmpty {
            SentrySDK.capture(message: "Empty user sessions")
        }
        await MainActor.run {
            self.userSessions = userSessions
            if let lastTenantId = UserDefaults.standard.string(forKey: "lotta-tenant-id") {
                _ = setSession(byTenantId: lastTenantId)
            }
            PushNotificationService.shared.startReceivingNotifications()
            self.initialized = true
        }
    }
    
    func setSession(byTenantId id: ID) -> Bool {
        if currentSessionTenantId == id {
            return true
        }
        if let session = userSessions.first(where: { $0.tenant.id == id }) {
            UserDefaults.standard.setValue(id, forKey: "lotta-tenant-id")
            currentSessionTenantId = id
            SentrySDK.configureScope { scope in
                scope.setContext(value: [
                    "id": session.tenant.id,
                    "slug": session.tenant.slug,
                ], key: "tenant")
                scope.setUser(session.user.toSentryUser())
            }
            return true
        }
        return false
    }
    
    func setSession(byTenantSlug slug: String) -> Bool {
        if let tenant = userSessions.first(where: { $0.tenant.slug == slug })?.tenant {
            return setSession(byTenantId: tenant.id)
        }
        return false
    }
    
    func add(session: UserSession) {
        userSessions.removeAll(where: {
            $0.user.id == session.user.id &&
            $0.tenant.id == session.tenant.id
        })
        userSessions.append(session)
        _ = self.setSession(byTenantId: session.tenant.id)
        PushNotificationService.shared.startReceivingNotifications()
    }
    
    func remove(session: UserSession) -> Void {
        Task {
            try? await session.deleteDevice()
            try? session.removeFromDisk()
            session.removeFromKeychain()
            
            session.api.resetCache()
        }
    }
    
    func removeCurrentSession() -> Void {
        if let session = currentSession {
            remove(session: session)
        }
        
        if let session = currentSession {
            currentSessionTenantId = session.tenant.id
            UserDefaults.standard.setValue(currentSessionTenantId, forKey: "lotta-tenant-id")
        }
    }
    
    func refreshAllSessions(force: Bool = false) async throws {
        for session in userSessions {
            try await session.loadConversations(force: force)
        }
    }
    
    func setApplicationBadgeNumber() async -> Void {
        var newBadgeNumber = 0
        for session in userSessions {
            let unreadMessages = (try? await session.getUnreadMessagesCount()) ?? 0
            newBadgeNumber += unreadMessages
        }
        try? await UNUserNotificationCenter.current().setBadgeCount(newBadgeNumber)
    }
    
    var currentSession: UserSession? {
        get {
            userSessions.first { $0.tenant.id == currentSessionTenantId } ?? userSessions.first
        }
    }
    
}
