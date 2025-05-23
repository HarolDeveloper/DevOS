//
//  DevOSApp.swift
//  DevOS
//
//  Created by H Lancheros Alvarez on 25/04/25.
//

import SwiftUI
import SwiftData

@main
struct DevOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
         
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
