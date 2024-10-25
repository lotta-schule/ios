//
//  MainView.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 22/09/2023.
//

import SwiftUI
import Sentry
import LottaCoreAPI

struct RootView: View {
    @Environment(ModelData.self) var modelData
    
    @State private var isShowLoginView = false
    
    var body: some View {
        ZStack {
            LottaLogoView()
            
            if modelData.initialized {
                if let session = modelData.currentSession {
                    TenantRootView()
                        .environment(session)
                        .environment(RouterData.shared)
                }
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
        .onAppear {
            Task {
                if (!modelData.initialized) {
                    await modelData.initializeSessions()
                } else {
                    do {
                        try await ModelData.shared.refreshAllSessions()
                    } catch {
                        SentrySDK.capture(error: error)
                        print("Error refreshing sessions: \(error)")
                    }
                }
            }
        }
    }
    
}
