//
//  NewConversationView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/11/2023.
//

import SwiftUI
import LottaCoreAPI

struct NewConversationView : View {
    @Environment(UserSession.self) private var userSession
    @Environment(RouterData.self) private var routerData
    
    var destination: NewMessageDestination
    
    var body: some View {
        VStack {
            Spacer()
            Text(getDescription())
            Spacer()
            
            MessageInputView(
                userId: getUser()?.id,
                groupId: getGroup()?.id
            ) { message in
                withAnimation(.bouncy) {
                    self.routerData.selectedConversationId = message.conversation.id
                }
            }
        }
        .navigationTitle(getNavigationTitle())
    }
    
    func getDescription() -> String {
        switch destination {
            case .user(let user):
            return "Neue Unterhaltung mit \(UserUtil.getVisibleName(for: user))"
            case .group(let group):
            return "Neue Unterhaltung in \(group.name)"
        }
    }
        
    func getUser() -> SearchUsersQuery.Data.User? {
        switch destination {
            case .user(let user):
                return user
            default:
                return nil
        }
    }
    
    func getGroup() -> GetCurrentUserQuery.Data.CurrentUser.Group? {
        switch destination {
            case .group(let group):
            return GetCurrentUserQuery.Data.CurrentUser.Group(_dataDict: DataDict(data: [
                    "id": group.id,
                    "name": group.name
                ], fulfilledFragments: []))
            default:
                return nil
        }
    }
    
    func getNavigationTitle() -> String {
        if let user = getUser() {
            UserUtil.getVisibleName(for: user)
        } else {
            getGroup()?.name ?? ""
        }
    }
}
