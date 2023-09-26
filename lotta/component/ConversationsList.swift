//
//  ConversationsList.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct ConversationsList : View {
    var conversations: [Conversation]
    var currentUser: User?
    var body: some View {
        List {
            ForEach(conversations) { conversation in
                NavigationLink {
                    MessageListView(conversation: conversation)
                } label: {
                    ConversationListItem(conversation: conversation, excluding: currentUser)
                }
            }
        // .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
    }
}
