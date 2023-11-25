//
//  MessageBubble.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct MessageBubble : View {
    @Environment(UserSession.self) private var userSession: UserSession
    @State private var isSharePresented = false
    
    var message: GetConversationQuery.Data.Conversation.Message
    var fromCurrentUser: Bool
    
    var body: some View {
        VStack {
            if let content = message.content {
                Text(content)
            }
            ForEach(getFiles(), id: \.self.id) { file in
                MessageBubbleFileRow(file: file)
            }
        }
        .padding(CGFloat(userSession.theme.spacing))
        .foregroundColor(userSession.theme.textColor.toColor())
        .background(
            fromCurrentUser
            ? userSession.theme.primaryColor.opacity(0.3)
            : userSession.theme.disabledColor.opacity(0.08)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: CGFloat(userSession.theme.borderRadius)
            )
            .stroke(
                fromCurrentUser
                ? userSession.theme.primaryColor.toColor()
                : userSession.theme.disabledColor.toColor().opacity(0.5),
                lineWidth: 1
            )
        )
        .cornerRadius(CGFloat(userSession.theme.borderRadius))
    }
    
    func getFiles() -> [GetConversationQuery.Data.Conversation.Message.File] {
        return message.files?.compactMap { $0 } ?? []
    }
}

