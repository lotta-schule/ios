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
            UserAvatar(user: userSession.user)
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
