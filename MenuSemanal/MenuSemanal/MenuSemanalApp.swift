//
//  MenuSemanalApp.swift
//  MenuSemanal
//

import SwiftUI

@main
struct MenuSemanalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
