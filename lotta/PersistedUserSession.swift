//
//  PersistedUserSession.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 03/11/2023.
//

import Foundation

struct PersistedUserSession {
    let tenant: Tenant
    let user: User
}

extension PersistedUserSession : Codable {}
