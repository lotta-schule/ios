//
//  SearchUserList.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 20/11/2023.
//

import SwiftUI
import LottaCoreAPI
import Apollo

struct SearchUserList: View {
    @Environment(UserSession.self) private var userSession: UserSession
    
    var onSelect: (SearchUsersQuery.Data.User) -> Void;
    
    @State private var searchText: String = ""
    @State private var searchResults: [SearchUsersQuery.Data.User] = []
    @State private var cancelCurrentSearchQuery: Cancellable?
    
    var body: some View {
        VStack {
            TextField("Nutzer suchen",
                      text: $searchText,
                      prompt: Text("Nutzer suchen")
            )
            .padding(.horizontal, CGFloat(userSession.theme.spacing))
            List {
                ForEach(searchResults, id: \.self.id) { user in
                    Button(action: {
                        onSelect(user)
                    }) {
                        HStack {
                            if let imageId = user.avatarImageFile?.id {
                                Avatar(url:
                                        imageId.getUrl(
                                            for: userSession.tenant,
                                            queryItems: [
                                                .init(name: "width", value: "100"),
                                                .init(name: "height", value: "100")
                                            ]
                                        ))
                            }
                            Text(UserUtil.getVisibleName(for: user))
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .onChange(of: searchText) { _, _ in
            runSearch()
        }
    }
    
    func runSearch() -> Void {
        cancelCurrentSearchQuery?.cancel()
        cancelCurrentSearchQuery = userSession.api.apollo.fetch(
            query: SearchUsersQuery(searchtext: searchText)
        ) { result in
            switch result {
            case .success(let graphqlResult):
                self.searchResults = graphqlResult.data?.users?.compactMap { $0 } ?? []
            case .failure(let error):
                // TODO: Better error handling
                print("error: \(error.localizedDescription)")
            }
        }
    }
}