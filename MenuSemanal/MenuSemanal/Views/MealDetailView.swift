//
//  MealDetailView.swift
//  MenuSemanal
//

import SwiftUI
import CoreData

struct MealDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var comida: Comida
    @State private var editingName: String = ""
    @State private var isEditingName = false
    @State private var newComponentName = ""
    @State private var showingAddComponent = false

    private var componentesSorted: [Componente] {
        ((comida.componentes as? Set<Componente>) ?? [])
            .sorted { ($0.nombre ?? "") < ($1.nombre ?? "") }
    }

    var body: some View {
        List {
            // Nombre del plato
            Section(String(localized: "detail.dish")) {
                if isEditingName {
                    HStack {
                        TextField(String(localized: "detail.dish.placeholder"), text: $editingName)
                            .onSubmit { saveName() }
                        Button(String(localized: "detail.save")) { saveName() }
                    }
                } else {
                    HStack {
                        Text(comida.nombre ?? String(localized: "detail.unnamed"))
                            .foregroundStyle(comida.nombre?.isEmpty ?? true ? .secondary : .primary)
                        Spacer()
                        Button {
                            editingName = comida.nombre ?? ""
                            isEditingName = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
            }

            // Componentes
            Section {
                ForEach(componentesSorted, id: \.objectID) { componente in
                    HStack {
                        Image(systemName: componente.disponible ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(componente.disponible ? .green : .secondary)
                            .onTapGesture {
                                toggleDisponible(componente: componente)
                            }
                        Text(componente.nombre ?? "")
                        Spacer()
                    }
                }
                .onDelete(perform: deleteComponentes)

                // Añadir componente inline
                if showingAddComponent {
                    HStack {
                        TextField(String(localized: "detail.component.placeholder"), text: $newComponentName)
                            .onSubmit { addComponente() }
                        Button(String(localized: "detail.add")) { addComponente() }
                            .disabled(newComponentName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            } header: {
                HStack {
                    Text("detail.components")
                    Spacer()
                    Button {
                        withAnimation { showingAddComponent.toggle() }
                    } label: {
                        Image(systemName: showingAddComponent ? "minus.circle" : "plus.circle")
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private var navigationTitle: String {
        let tipo = comida.tipo == "almuerzo" ? String(localized: "meal.lunch") : String(localized: "meal.dinner")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        formatter.locale = .current
        let dateStr = comida.fecha.map { formatter.string(from: $0) } ?? ""
        return "\(tipo) · \(dateStr)"
    }

    private func saveName() {
        let name = editingName.trimmingCharacters(in: .whitespaces)
        comida.nombre = name.isEmpty ? nil : name
        saveContext()
        isEditingName = false
    }

    private func toggleDisponible(componente: Componente) {
        componente.disponible.toggle()
        saveContext()
    }

    private func addComponente() {
        let name = newComponentName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let comp = Componente(context: viewContext)
        comp.id = UUID()
        comp.nombre = name
        comp.disponible = true
        comp.comida = comida
        saveContext()
        newComponentName = ""
        showingAddComponent = false
    }

    private func deleteComponentes(at offsets: IndexSet) {
        offsets.map { componentesSorted[$0] }.forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error guardando: \(nsError)")
        }
    }
}
