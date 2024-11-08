//
//  MessageBubble.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import QuickLook
import LottaCoreAPI

struct MessageBubble : View {
    @Environment(UserSession.self) private var userSession: UserSession
    @State private var isSharePresented = false
    
    var message: GetConversationQuery.Data.Conversation.Message
    var fromCurrentUser: Bool
    var isGroupChat: Bool
    
    var body: some View {
        VStack {
            if let content = message.content {
                Text(content)
                    .lineLimit(.none)
            }
            ForEach(getFiles().indices, id: \.self) { index in
                MessageBubbleFileRow(file: getFiles()[index], index: index, dataSource: getFilesPreviewDataSource())
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
            UnevenRoundedRectangle(
                topLeadingRadius: CGFloat(userSession.theme.borderRadius),
                bottomLeadingRadius: fromCurrentUser ? CGFloat(userSession.theme.borderRadius) : 0,
                bottomTrailingRadius: fromCurrentUser ? 0 : CGFloat(userSession.theme.borderRadius),
                topTrailingRadius: CGFloat(userSession.theme.borderRadius)
            )
            .stroke(
                fromCurrentUser
                ? userSession.theme.primaryColor.toColor()
                : userSession.theme.disabledColor.toColor().opacity(0.5),
                lineWidth: 1
            )
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(
            maxWidth: UIScreen.main.bounds.size.width * 0.7,
            alignment: fromCurrentUser ? .trailing : .leading
        )

    }
    
    func getFiles() -> [GetConversationQuery.Data.Conversation.Message.File] {
        return message.files?.compactMap { $0 } ?? []
    }
    
    func getFilesPreviewDataSource() -> MessageQLPreviewDataSource {
        return MessageQLPreviewDataSource(session: userSession, files: getFiles())
    }
}

