//
//  MessageBubble.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageBubble : View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        Text(message.content ?? "[File-Message]")
            .padding(CGFloat(userSession.theme.spacing))
            .foregroundColor(userSession.theme.textColor)
            .background(
                fromCurrentUser
                    ? userSession.theme.primaryColor.opacity(0.3)
                    : userSession.theme.disabledColor.opacity(0.08)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: CGFloat(userSession.theme.borderRadius) * 3
                )
                .stroke(
                    fromCurrentUser
                        ? userSession.theme.primaryColor
                        : userSession.theme.disabledColor.opacity(0.5),
                    lineWidth: 1
                )
            )
            .cornerRadius(CGFloat(userSession.theme.borderRadius) * 3)
    }
}

#Preview {
    MessageBubble(
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
