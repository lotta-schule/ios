//
//  MessageView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageRow : View {
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            if fromCurrentUser {
                Spacer()
            } else {
                UserAvatar(user: message.user)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.leading, 8)
            }
            MessageBubble(
                message: message,
                fromCurrentUser: fromCurrentUser
            )
            if fromCurrentUser {
                UserAvatar(user: message.user)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.trailing, 8)
            } else {
                Spacer()
            }
        }
    }
}
