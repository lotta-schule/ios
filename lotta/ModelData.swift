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
import JWTDecode

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
    
    private var currentSessionTenantId: ID?
    
    /*
     TODO: add an initialize when we have persistence
    init() {
        let keychain = KeychainSwift()
        if let tid = UserDefaults.standard.string(forKey: "lotta-tenant-id"),
           let refreshToken = keychain.get("\(tid)--refresh-token"),
           let jwt = try? JWTDecode.decode(jwt: refreshToken) {
            if !jwt.expired {
                self.userSessions.append(
                    UserSession(
                        tenant: <#T##Tenant#>,
                        authInfo: <#T##AuthInfo#>,
                        user: <#T##User#>
                    )
                )
            }
        }
    }
    */
    
    func setSession(byTenantId id: ID) -> Bool {
        if currentSessionTenantId == id {
            return true
        }
        if userSessions.contains(where: { $0.tenant.id == id }) {
            UserDefaults.standard.setValue(id, forKey: "lotta-tenant-id")
            currentSessionTenantId = id
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
