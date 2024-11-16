//
//  ProfileView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 23/09/2023.
//

import SwiftUI

struct ProfileView : View {
    @Environment(ModelData.self) var modelData
    @Environment(RouterData.self) var routerData
    @Environment(\.openURL) var openURL
    
    @State private var isShowLoginView = false
    @State private var isShowFeedbackView = false

    var body: some View {
        VStack {
            List(selection: .constant(modelData.currentSession?.tenant.id)) {
                Section(header: Text("Angemeldet als")) {
                    ForEach(modelData.userSessions, id: \.tenant.id) { userSession in
                        Button(action: {
                            if modelData.setSession(byTenantId: userSession.tenant.id) {
                                routerData.rootSection = .messaging
                            }
                        }) {
                            HStack {
                                UserSessionListItem(userSession: userSession)
                            }
                        }
                        .id(userSession.tenant.id)
                    }
                    Button(
                        modelData.userSessions.count > 1 ? "Aktuelles Benutzerkonto abmelden" : "Abmelden",
                        systemImage: "door.left.hand.open") {
                        modelData.removeCurrentSession()
                    }
                }
                Section {
                    Button("Benutzerkonto hinzufügen", systemImage: "person.crop.circle.badge.plus") {
                        isShowLoginView.toggle()
                    }
                }
                Section(header: Text("Lotta")) {
                    HStack {
                        Text("Version:")
                        Spacer()
                        Text(getAppVersion())
                    }
                    HStack {
                        Text("API Endpunkt:")
                        Spacer()
                        Text(LOTTA_API_HOST)
                    }
                    Button("Feedback senden") {
                        isShowFeedbackView.toggle()
                    }
                    Button("Quelltext anzeigen") {
                        openURL(URL(string: "https://github.com/lotta-schule/ios")!)
                    }
                }
            }

            .sheet(isPresented: $isShowLoginView) {
                LoginView(
                    disablingTenantSlugs: modelData.userSessions.map { $0.tenant.slug },
                    defaultLoginMail: modelData.userSessions.first?.user.email ?? ""
                ) { userSession in
                    modelData.add(session: userSession)
                    isShowLoginView.toggle()
                }
            }
            .sheet(isPresented: $isShowFeedbackView) {
                FeedbackView(name: modelData.currentSession?.user.name ?? "", email: modelData.currentSession?.user.email ?? "") {
                    isShowFeedbackView.toggle()
                }
            }

        }
    }
    
    func getAppVersion() -> String {
        let shortVersion = getInfo("CFBundleShortVersionString")
        let buildVersion = getInfo("CFBundleVersion")
        
        return "\(shortVersion) (\(buildVersion))"
    }
    
    func getInfo(_ key: String) -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            return ""
        }
        return infoDict[key] as? String ?? ""
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
                tenant: Tenant(
                    id: "0",
                    title: "test",
                    slug: "test"
                ),
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
                tenant: Tenant(
                    id: "0",
                    title: "test",
                    slug: "test"
                ),
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
                tenant: Tenant(
                    id: "0",
                    title: "test",
                    slug: "test"
                ),
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
                tenant: Tenant(
                    id: "0",
                    title: "test",
                    slug: "test"
                ),
                id: "2",
                name: "Napoleon",
                nickname: ""
            )
        )
        modelData.userSessions = [userSession1, userSession2, userSession3]
        
        return modelData
    }
}
