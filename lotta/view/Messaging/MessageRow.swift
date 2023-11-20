//
//  MessageView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI

struct MessageRow : View {
    @Environment(UserSession.self) private var userSession
    var message: Message
    var fromCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: CGFloat(userSession.theme.spacing)) {
            if fromCurrentUser {
                Spacer()
            } else {
                UserAvatar(user: message.user)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.leading, CGFloat(userSession.theme.borderRadius))
            }
            VStack(alignment: fromCurrentUser ? .trailing : .leading) {
                MessageBubble(
                    message: message,
                    fromCurrentUser: fromCurrentUser
                )
                .padding(.trailing, CGFloat(integerLiteral: userSession.theme.spacing))
                Text("\(fromCurrentUser ? "" : message.user.visibleName + " • ")\(formatDate(message.insertedAt))")
                    .font(.footnote)
                    .foregroundStyle(userSession.theme.disabledColor)
                    .padding(.trailing, CGFloat(integerLiteral: userSession.theme.spacing))
                    .padding(.top, CGFloat(integerLiteral: userSession.theme.spacing) * -0.75)
            }
            if fromCurrentUser {
                UserAvatar(user: message.user)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.trailing, CGFloat(integerLiteral: userSession.theme.spacing))
            } else {
                Spacer()
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "de-DE")
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: date)
    }
}

#Preview {
    MessageRow(
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
    .environment(
        UserSession(
            tenant: Tenant(
                id: "0",
                title: "",
                slug: "slug"),
            authInfo: AuthInfo(),
            user: User(tenant: Tenant(
                id: "0",
                title: "",
                slug: "slug"), id: "0")
        )
    )
}
