//
//  MainTabView.swift
//  MenuSemanal
//

import SwiftUI
import CoreData

struct MainTabView: View {
    var body: some View {
        TabView {
            WeeklyMenuView()
                .tabItem {
                    Label("tab.menu", systemImage: "fork.knife")
                }

            ShoppingListView()
                .tabItem {
                    Label("tab.shopping", systemImage: "cart")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
