//
//  lottaApp.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import SwiftUI
import Sentry

import SwiftData

@main
struct lottaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var modelData = ModelData.shared
    
    init() {
        SentrySDK.start { options in
            options.dsn = "https://5beb3826272f086c5b8cde2d02cc503d@o282982.ingest.sentry.io/4505983794806784"
            options.debug = false
            options.tracesSampleRate = 0.1

            options.attachScreenshot = true // This adds a screenshot to the error events
            options.attachViewHierarchy = true // This adds the view hierarchy to the error events
        }
    }
    //var sharedModelContainer: ModelContainer = {
    //    let schema = Schema([
    //        Tenant.self
    //    ])
    //    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    //    do {
    //        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    //    } catch {
    //        fatalError("Could not create ModelContainer: \(error)")
    //    }
    //}()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(ModelData.shared)
        // .modelContext(ModelContext(sharedModelContainer))
    }
}
