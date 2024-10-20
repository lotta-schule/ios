//
//  UserSessionListItem.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 16/02/2024.
//

import Foundation
import SwiftUI

struct UserSessionListItem: View {
    
    var userSession: UserSession
    
    @State private var badgeCount = 0
    
    var body: some View {
        HStack {
            ZStack {
                UserAvatar(user: userSession.user)
                OnlineBullet(session: userSession)
                    .frame(width: 11, height: 11)
                    .offset(x: 16.5, y: 16.5)
            }
            VStack(alignment: .leading) {
                Text(userSession.tenant.title)
                Text(userSession.user.visibleName)
                    .font(.footnote)
            }
        }
        .badge(badgeCount)
        .onAppear {
            Task {
                badgeCount = (try? await userSession.getUnreadMessagesCount()) ?? 0
            }
        }
    }
}
