//
//  MenuSemanalApp.swift
//  MenuSemanal
//
//  Created by Ion Jaureguialzo Sarasola on 23/05/2026.
//

import SwiftUI
import CoreData

@main
struct MenuSemanalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
