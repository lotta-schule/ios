//
//  SearchUserList.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 20/11/2023.
//

import SwiftUI
import LottaCoreAPI

struct SearchUserList: View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    var onSelect: (User) -> Void;
    
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    
    var body: some View {
        VStack {
            TextField("Nutzer suchen",
                      text: $searchText,
                      prompt: Text("Nutzer suchen")
            )
            .padding(.horizontal, CGFloat(userSession.theme.spacing))
            List {
                ForEach(searchResults) { user in
                    Button(action: {
                        onSelect(user)
                    }) {
                        HStack {
                            UserAvatar(user: user)
                            Text(user.visibleName)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .onChange(of: searchText) { _, _ in
            Task {
                await runSearch()
            }
        }
    }
    
    func runSearch() async -> Void {
        do {
            let graphqlResult = try await userSession.api.apollo.fetchAsync(
                query: SearchUsersQuery(searchtext: searchText)
            )
            searchResults = graphqlResult.users?.map {
                User(in: userSession.tenant, from: $0!)
            } ?? []
        } catch {
            // TODO: Better error handling
            print("error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SearchUserList(onSelect: { print($0) })
}
