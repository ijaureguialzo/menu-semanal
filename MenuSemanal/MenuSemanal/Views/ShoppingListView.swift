//
//  ShoppingListView.swift
//  MenuSemanal
//

import SwiftUI
import CoreData

struct ShoppingListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var navigator = WeekNavigator()

    @FetchRequest private var comidas: FetchedResults<Comida>

    init() {
        // El fetch pedirá comidas de la semana actual (se recalcula en onAppear y con el navigator)
        // Usamos el fetch sin predicado aquí y filtramos en computed properties
        _comidas = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Comida.fecha, ascending: true)],
            predicate: nil
        )
    }

    private var weekStart: Date { navigator.weekStart }
    private var weekEnd: Date { Calendar.current.date(byAdding: .day, value: 7, to: weekStart)! }

    private var componentesFaltantes: [Componente] {
        comidas
            .filter { c in
                guard let fecha = c.fecha else { return false }
                return fecha >= weekStart && fecha < weekEnd
            }
            .flatMap { ($0.componentes as? Set<Componente>) ?? [] }
            .filter { !$0.disponible }
            .sorted { ($0.nombre ?? "") < ($1.nombre ?? "") }
    }

    var body: some View {
        NavigationStack {
            Group {
                if componentesFaltantes.isEmpty {
                    emptyView
                } else {
                    listView
                }
            }
            .navigationTitle(String(localized: "tab.shopping"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    weekNavigatorButtons
                }
                if !componentesFaltantes.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(String(localized: "shopping.markAll")) {
                            markAllAvailable()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subvistas

    private var emptyView: some View {
        ContentUnavailableView(
            String(localized: "shopping.empty.title"),
            systemImage: "cart.badge.checkmark",
            description: Text("shopping.empty.description")
        )
    }

    private var listView: some View {
        List {
            Section {
                ForEach(componentesFaltantes, id: \.objectID) { componente in
                    HStack {
                        Image(systemName: componente.disponible ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(componente.disponible ? .green : .accentColor)
                            .onTapGesture {
                                toggleDisponible(componente: componente)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(componente.nombre ?? "")
                            if let comida = componente.comida {
                                Text("\(comida.nombre ?? "") · \(dayLabel(for: comida.fecha))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                Text("shopping.missing.header \(componentesFaltantes.count)")
            }
        }
    }

    private var weekNavigatorButtons: some View {
        HStack {
            Button { withAnimation { navigator.goToPreviousWeek() } } label: {
                Image(systemName: "chevron.left")
            }
            Text(weekRangeLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button { withAnimation { navigator.goToNextWeek() } } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    // MARK: - Helpers

    private func toggleDisponible(componente: Componente) {
        componente.disponible.toggle()
        saveContext()
    }

    private func markAllAvailable() {
        componentesFaltantes.forEach { $0.disponible = true }
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error guardando: \(error)")
        }
    }

    private func dayLabel(for date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d"
        formatter.locale = .current
        return formatter.string(from: date).capitalized
    }

    private var weekRangeLabel: String {
        let start = weekStart
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = .current
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }
}

#Preview {
    ShoppingListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
