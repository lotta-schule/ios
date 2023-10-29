//
//  ConversationsList.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct ConversationsList : View {
    @Environment(UserSession.self) private var userSession

    var body: some View {
        List {
            ForEach(userSession.conversations, id: \.id) { conversation in
                NavigationLink {
                    ConversationView(conversation: conversation)
                } label: {
                    ConversationListItem(conversation: conversation, excluding: userSession.user)
                }
            }
        // .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
    }
}
