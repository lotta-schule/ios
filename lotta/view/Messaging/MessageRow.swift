//
//  MessageView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageRow : View {
    @Environment(ModelData.self) private var modelData
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: CGFloat(modelData.theme.spacing)) {
            if fromCurrentUser {
                Spacer()
            } else {
                UserAvatar(user: message.user)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.leading, CGFloat(modelData.theme.borderRadius))
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

#Preview {
    MessageRow(
        message: Message(
            id: "1",
            user: User(id: "1", name: "Rosa Luxemburg", nickname: nil),
            content: "Lorem ipsum dolor sit amed bla bla bli blub.",
            createdAt: Date.now
        ),
        fromCurrentUser: true
    )
    .environment(ModelData())
}
