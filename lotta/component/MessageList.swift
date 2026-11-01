//
//  MessageListView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import Sentry
import SwiftUI
import LottaCoreAPI

struct MessageList : View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    var messages: [GetConversationQuery.Data.Conversation.Message]
    var hasMoreOlder: Bool = false
    var isLoadingOlder: Bool = false
    var onLoadOlder: () -> Void = {}
    var isGroupChat: Bool
    
    @State private var canLoadOlder = false
    @State private var loaderVisible = false
    @State private var sortedMessages: [GetConversationQuery.Data.Conversation.Message] = []
    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            ScrollView {
                LazyVStack {
                    if hasMoreOlder {
                        ZStack {
                            if isLoadingOlder {
                                ProgressView().padding()
                            } else {
                                Color.clear.frame(height: 1)
                            }
                        }
                        .id("older-messages-loader")
                        .onAppear { loaderVisible = true; if canLoadOlder { onLoadOlder() } }
                        .onDisappear { loaderVisible = false }
                    }
                    ForEach(sortedMessages, id: \.id.description) { msg in renderMessage(msg); }
                }
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: isLoadingOlder) { _, loading in
                // If the trigger is still on screen after a page arrived, there is more room to fill: load the next page
                if !loading && loaderVisible && canLoadOlder {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if loaderVisible { onLoadOlder() }
                    }
                }
            }
            .onChange(of: sortedMessages.first?.id) { oldFirstId, newFirstId in
                // Older messages were prepended: keep the previously first message in place
                guard let oldFirstId = oldFirstId, newFirstId != oldFirstId else { return }
                DispatchQueue.main.async {
                    scrollViewReader.scrollTo(oldFirstId, anchor: .top)
                }
            }
            .onChange(of: sortedMessages.last, initial: true) { oldLastElement, newLastElement  in
                guard let newLastElement = newLastElement else { return }
                if oldLastElement == nil {
                    scrollViewReader.scrollTo(newLastElement.id, anchor: .bottomTrailing)
                    // Only allow loading older messages once we have settled at the bottom
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { canLoadOlder = true }
                } else {
                    withAnimation {
                        scrollViewReader.scrollTo(newLastElement.id, anchor: .bottomTrailing)
                    }
                }
            }
        }
        .onChange(of: messages, initial: true) {
            sortedMessages = messages.sorted(by: {
                if let i1 = Int($0.id), let i2 = Int($1.id) { return i1 < i2 }
                let d1 = $0.updatedAt.toDate()
                let d2 = $1.updatedAt.toDate()
                return d1.compare(d2) == .orderedAscending
            })
        }
    }
    
    private func renderMessage(_ message: GetConversationQuery.Data.Conversation.Message) -> some View {
        
        MessageRow(
            message: message,
            fromCurrentUser: message.user?.id == userSession.user.id,
            isGroupChat: isGroupChat
        )
        .padding(.horizontal, CGFloat(userSession.theme.spacing))
        .id(message.id)
    }
    
}
