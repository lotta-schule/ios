//
//  MessageInput.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Sentry
import SwiftUI
import LottaCoreAPI

struct MessageInput : View {
    @Environment(UserSession.self) var userSession: UserSession
    var user: User?
    var group: Group?
    var onSent: (Message) -> ()
    
    @State var content = ""
    
    var body: some View {
        HStack {
            TextField("Message...", text: $content, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(5)
                .submitLabel(.send)
                .frame(minHeight: CGFloat(30))
                .onSubmit {
                    Task {
                        await sendMessage()
                    }
                }
            Button(action: {
                Task {
                    await sendMessage()
                }
            }, label: {
                Image(systemName: "paperplane")
                    .foregroundStyle(.primary)
            })
        }
        .padding(.horizontal, CGFloat(userSession.theme.spacing))
    }
    
    func sendMessage() async -> Void {
        do {
            let message: Message? =
                if let user = user {
                    try await userSession.sendMessage(content, to: user)
                } else if let group = group {
                    try await userSession.sendMessage(content, to: group)
                } else {
                    nil
                }
            if let message = message {
                onSent(message)
                content = ""
            }
        } catch {
            SentrySDK.capture(error: error)
            print("error: \(error)")
        }
    }
}

#Preview {
    MessageInput { message in
        print(message)
    }
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
