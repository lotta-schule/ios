//
//  lottaApp.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 18/09/2023.
//

import SwiftUI
import SwiftData

@main
struct lottaApp: App {
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
        .environment(ModelData())
        // .modelContext(ModelContext(sharedModelContainer))
    }
}
