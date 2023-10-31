//
//  MessageBubble.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageBubble : View {
    @Environment(UserSession.self) private var userSession: UserSession
    @State private var isSharePresented = false
    
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        VStack {
            if let content = message.content {
                Text(content)
            }
            ForEach(message.files) { file in
                MessageBubbleFileRow(file: file)
            }
        }
        .padding(CGFloat(userSession.theme.spacing))
        .foregroundColor(userSession.theme.textColor)
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
                ? userSession.theme.primaryColor
                : userSession.theme.disabledColor.opacity(0.5),
                lineWidth: 1
            )
        )
        .cornerRadius(CGFloat(userSession.theme.borderRadius))
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(
            message: Message(
                tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"),
                id: "1",
                user: User(tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"), id: "1", name: "Rosa Luxemburg", nickname: nil),
                content: "Lorem ipsum dolor sit amed bla bla bli blub.",
                createdAt: Date.now,
                files: []
            ),
            fromCurrentUser: true
        )
        .environment(ModelData())
        .environment(
            UserSession(
                tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"),
                authInfo: AuthInfo(),
                user: User(
                    tenant: Tenant(
                        id: "0",
                        title: "",
                        slug: "slug"
                    ),
                    id: "0"
                )
            )
        )
        .environment(RouterData())
        .previewLayout(.sizeThatFits)
        .previewDisplayName("MessageBubble with text")
        
        MessageBubble(
            message: Message(
                tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"),
                id: "1",
                user: User(
                    tenant: Tenant(
                        id: "0",
                        title: "",
                        slug: "slug"
                    ),
                    id: "1",
                    name: "Rosa Luxemburg",
                    nickname: nil
                ),
                content: nil,
                createdAt: Date.now,
                files: [
                    LottaFile(
                        tenant: Tenant(
                            id: "0",
                            title: "",
                            slug: "slug"
                        ),
                        id: "1",
                        fileName: "test.jpg",
                        fileType: "IMAGE"
                    )
                ]
            ),
            fromCurrentUser: true
        )
        .environment(ModelData())
        .environment(
            UserSession(
                tenant: Tenant(
                    id: "0",
                    title: "",
                    slug: "slug"),
                authInfo: AuthInfo(),
                user: User(
                    tenant: Tenant(
                        id: "0",
                        title: "",
                        slug: "slug"
                    ),
                    id: "0"
                )
            )
        )
        .environment(RouterData())
        .previewLayout(.sizeThatFits)
        .previewDisplayName("MessageBubble with file")
    }
}
