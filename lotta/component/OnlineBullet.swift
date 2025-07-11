//
//  OnlineBullet.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 19/10/2024.
//

import SwiftUI

struct OnlineBullet: View {
    var userSession: UserSession
    
    @State private var timer: Timer?
    @State private var isOnline: Bool = false
    
    init(session userSession: UserSession) {
        self.userSession = userSession
        self.timer = nil
        self.isOnline = userSession.api.isWSConnected()
    }
    
    var body: some View {
        Circle()
            .fill(isOnline ? .green : .red)
            .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    MainActor.assumeIsolated {
                        isOnline = userSession.api.isWSConnected()
                    }
                }
            }
            .onDisappear {
                if let timer {
                    timer.invalidate()
                }
            }
    }
}

#Preview {
    OnlineBullet(
        session: UserSession(
            tenant: Tenant(
                id: "1",
                title: "Test",
                slug: "test"
            ),
            authInfo: AuthInfo(),
            user: User(
                tenant: Tenant(
                    id: "1",
                    title: "Test",
                    slug: "test"
                ),
                id: "1"
            )
        )
    )
}
