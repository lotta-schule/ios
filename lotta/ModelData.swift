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
import KeychainSwift

let keychain = KeychainSwift()

enum AuthenticationResult {
    case success
    case error(Error)
}

enum AuthenticationError: Error {
    case invalidResponse(String)
}

@Observable final class ModelData {
    static let shared = ModelData()
    
    var userSessions = UserSession.readFromDisk()
    
    private var currentSessionTenantId: ID?
    
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
            $0.tenant.id == session.tenant.id
        })
        userSessions.append(session)
        _ = self.setSession(byTenantId: session.tenant.id)
    }
    
    func remove(session: UserSession) -> Void {
        try? session.removeFromDisk()
        self.userSessions.removeAll { existingSession in
            existingSession.tenant.id == session.tenant.id
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
    
    var currentSession: UserSession? {
        get {
            userSessions.first { $0.tenant.id == currentSessionTenantId } ?? userSessions.first
        }
    }
}
