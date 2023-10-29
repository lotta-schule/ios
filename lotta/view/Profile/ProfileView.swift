//
//  ProfileView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//

import SwiftUI

struct ProfileView : View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Angemeldet als")) {
                    ForEach(modelData.userSessions, id: \.tenant.id) { userSession in
                        HStack {
                            UserAvatar(user: userSession.user)
                            Text(userSession.user.visibleName)
                        }
                    }
                }
                
                Section {
                    Button("Abmelden") {
                        modelData.removeCurrentSession()
                    }
                }
            }
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environment(ProfileView_Previews.singleTenantModelData)
        
        ProfileView()
            .environment(ProfileView_Previews.multiTenantModelData)
    }
    
    static var singleTenantModelData: ModelData {
        let modelData = ModelData()
        let userSession = UserSession(
            tenant: Tenant(
                id: "0",
                title: "test",
                slug: "test"
            ),
            authInfo: AuthInfo(),
            user: User(
                id: "0",
                name: "Napoleon Bonaparte",
                nickname: "Naps"
            )
        )
        modelData.userSessions = [userSession]
        
        return modelData
    }
    
    static var multiTenantModelData: ModelData {
        let modelData = ModelData()
        let userSession1 = UserSession(
            tenant: Tenant(
                id: "0",
                title: "test",
                slug: "test"
            ),
            authInfo: AuthInfo(),
            user: User(
                id: "0",
                name: "Napoleon Bonaparte",
                nickname: "Naps"
            )
        )
        let userSession2 = UserSession(
            tenant: Tenant(
                id: "2",
                title: "test2",
                slug: "test2"
            ),
            authInfo: AuthInfo(),
            user: User(
                id: "5",
                name: "Napoleon Bonaparte",
                nickname: "Napoleon"
            )
        )
        let userSession3 = UserSession(
            tenant: Tenant(
                id: "6",
                title: "test3",
                slug: "test3"
            ),
            authInfo: AuthInfo(),
            user: User(
                id: "2",
                name: "Napoleon",
                nickname: ""
            )
        )
        modelData.userSessions = [userSession1, userSession2, userSession3]
        
        return modelData
    }
}
