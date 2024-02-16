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
                    .navigationTitle("Nutzer anschreiben")
                ) {
                    Text("Nutzer suchen")
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
                        .navigationTitle("Gruppe anschreiben")
                ) {
                    Text("Gruppe wählen")
                }
            }
            .navigationTitle("Neue Nachricht")
        }
    }
}

#Preview {
    CreateConversationView()
}
