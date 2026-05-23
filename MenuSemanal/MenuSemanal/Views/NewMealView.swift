//
//  NewMealView.swift
//  MenuSemanal
//

import SwiftUI
import CoreData

/// Vista para crear una nueva comida en una fecha y tipo específicos.
struct NewMealView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let tipo: String

    @State private var nombre = ""

    var body: some View {
        Form {
            Section(String(localized: "detail.dish")) {
                TextField(String(localized: "detail.dish.placeholder"), text: $nombre)
                    .submitLabel(.done)
                    .onSubmit { save() }
            }

            Section {
                Button(String(localized: "detail.save")) { save() }
                    .disabled(nombre.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        let tipoStr = tipo == "almuerzo" ? String(localized: "meal.lunch") : String(localized: "meal.dinner")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        formatter.locale = .current
        return "\(tipoStr) · \(formatter.string(from: date))"
    }

    private func save() {
        let name = nombre.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let comida = Comida(context: viewContext)
        comida.id = UUID()
        comida.fecha = Calendar.current.startOfDay(for: date)
        comida.tipo = tipo
        comida.nombre = name
        do {
            try viewContext.save()
        } catch {
            print("Error creando comida: \(error)")
        }
        dismiss()
    }
}
