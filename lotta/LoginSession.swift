//
//  CurrentSession.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//
import SwiftUI

struct LoginSession {
    var user: User?
    var token: String?
}

extension LoginSession: Equatable {
    static func == (lhs: LoginSession, rhs: LoginSession) -> Bool {
        return lhs.token == rhs.token
    }
}
