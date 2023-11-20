//
//  CreateConversationView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/11/2023.
//

import SwiftUI

struct CreateConversationView: View {
    @Environment(UserSession.self) var userSession: UserSession
    
    var onSelect: (NewMessageDestination) -> Void = { destination in }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: 
                                VStack {
                    SearchUserList(onSelect: { user in
                        onSelect(.user(user))
                    })
                }
                ) {
                    Text("Nachricht an Nutzer senden")
                }
                
                NavigationLink(
                    destination:
                        List {
                            ForEach(userSession.user.groups ?? []) { group in
                                Button(action: {onSelect(.group(group)) } ) {
                                    Text(group.name)
                                }
                            }
                        }
                ) {
                    Text("Nachricht an Gruppe senden")
                }
            }
            .navigationTitle("Neue Nachricht senden")
        }
    }
}

#Preview {
    CreateConversationView()
}
