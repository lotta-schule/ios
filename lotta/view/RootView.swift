//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import LottaCoreAPI

struct RootView: View {
    @Environment(ModelData.self) var modelData
    
    @State private var isShowLoginView = false
    
    var body: some View {
        ZStack {
            LottaLogoView()
            if let session = modelData.currentSession {
                TenantRootView()
                    .environment(session)
                    .environment(RouterData.shared)
            }
        }
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $isShowLoginView) {
            LoginView() { userSession in
                modelData.add(session: userSession)
                isShowLoginView.toggle()
            }
        }
        .onChange(of: modelData.currentSession, initial: true) {
            if modelData.currentSession == nil && modelData.initialized {
                isShowLoginView = true
            }
        }
        .onChange(of: modelData.initialized, initial: true) {
            if modelData.currentSession == nil && modelData.initialized {
                isShowLoginView = true
            }
        }
        .onChange(of: modelData.userSessions) {
            modelData.setApplicationBadgeNumber()
        }
        .onAppear {
            Task {
                await modelData.initializeSessions()
            }
        }
    }
    
}
