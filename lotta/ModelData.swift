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
    var userSessions = [UserSession]()
    
    private var currentSessionSlug = UserDefaults.standard.string(forKey: "lotta-tenant-slug")
    
    func setSession(bySlug slug: String) -> Void {
        if userSessions.contains(where: { $0.tenant.slug == slug }) {
            UserDefaults.standard.setValue(slug, forKey: "lotta-tenant-slug")
            currentSessionSlug = slug
        }
    }
    
    func add(session: UserSession) {
        userSessions.removeAll(where: {
            $0.tenant.id == session.tenant.id
        })
        userSessions.append(session)
        self.setSession(bySlug: session.tenant.slug)
    }
    
    var currentSession: UserSession? {
        get {
            userSessions.first { $0.tenant.slug == currentSessionSlug }
        }
    }
}
