//
//  MessageBubble.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageBubble : View {
    @Environment(ModelData.self) private var modelData: ModelData
    
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        Text(message.content ?? "[File-Message]")
            .padding(CGFloat(modelData.theme.spacing))
            .foregroundColor(modelData.theme.textColor)
            .background(
                fromCurrentUser
                    ? modelData.theme.primaryColor.opacity(0.3)
                    : modelData.theme.disabledColor.opacity(0.08)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: CGFloat(modelData.theme.borderRadius) * 3
                )
                .stroke(
                    fromCurrentUser
                        ? modelData.theme.primaryColor
                        : modelData.theme.disabledColor.opacity(0.5),
                    lineWidth: 1
                )
            )
            .cornerRadius(CGFloat(modelData.theme.borderRadius) * 3)
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
