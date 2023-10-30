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

enum AuthenticationResult {
    case success
    case error(Error)
}

enum AuthenticationError: Error {
    case invalidResponse(String)
}

@Observable final class ModelData {
    static let shared = ModelData()
    
    var userSessions = [UserSession]()
    
    private var currentSessionSlug = UserDefaults.standard.string(forKey: "lotta-tenant-slug")
    
    func setSession(bySlug slug: String) -> Bool {
        if currentSessionSlug == slug {
            return true
        }
        if userSessions.contains(where: { $0.tenant.slug == slug }) {
            UserDefaults.standard.setValue(slug, forKey: "lotta-tenant-slug")
            currentSessionSlug = slug
            return true
        }
        return false
    }
    
    func add(session: UserSession) {
        userSessions.removeAll(where: {
            $0.tenant.id == session.tenant.id
        })
        userSessions.append(session)
        _ = self.setSession(bySlug: session.tenant.slug)
    }
    
    func remove(session: UserSession) -> Void {
        self.userSessions.removeAll { existingSession in
            existingSession.tenant.id == session.tenant.id
        }
    }
    
    func removeCurrentSession() -> Void {
        if let session = currentSession {
            remove(session: session)
        }
        
        if let session = currentSession {
            currentSessionSlug = session.tenant.slug
            UserDefaults.standard.setValue(currentSessionSlug, forKey: "lotta-tenant-slug")
        }
    }
    
    var currentSession: UserSession? {
        get {
            userSessions.first { $0.tenant.slug == currentSessionSlug } ?? userSessions.first
        }
    }
}
