//
//  DayMenuView.swift
//  MenuSemanal
//

import SwiftUI
import CoreData

struct DayMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let date: Date
    var compact: Bool = false

    @FetchRequest private var comidas: FetchedResults<Comida>

    init(date: Date, compact: Bool = false) {
        self.date = date
        self.compact = compact

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        _comidas = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Comida.tipo, ascending: true)],
            predicate: NSPredicate(format: "fecha >= %@ AND fecha < %@", start as CVarArg, end as CVarArg)
        )
    }

    var body: some View {
        if compact {
            compactView
        } else {
            fullView
        }
    }

    // MARK: - Vista completa (iPhone)

    private var fullView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dayHeader)
                .font(.headline)
                .foregroundStyle(isToday ? .accentColor : .primary)

            HStack(spacing: 8) {
                mealCell(tipo: "almuerzo", label: String(localized: "meal.lunch"))
                mealCell(tipo: "cena", label: String(localized: "meal.dinner"))
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }

    // MARK: - Vista compacta (iPad, cuadrícula)

    private var compactView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dayHeader)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(isToday ? .accentColor : .secondary)

            ForEach(["almuerzo", "cena"], id: \.self) { tipo in
                if let comida = comidas.first(where: { $0.tipo == tipo }) {
                    NavigationLink(destination: MealDetailView(comida: comida)) {
                        Text(comida.nombre ?? "")
                            .font(.caption2)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    NavigationLink(destination: NewMealView(date: date, tipo: tipo)) {
                        Text(tipo == "almuerzo" ? String(localized: "meal.lunch") : String(localized: "meal.dinner"))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Celda de comida individual

    @ViewBuilder
    private func mealCell(tipo: String, label: String) -> some View {
        let comida = comidas.first(where: { $0.tipo == tipo })

        Group {
            if let comida = comida {
                NavigationLink(destination: MealDetailView(comida: comida)) {
                    mealContent(nombre: comida.nombre ?? "", label: label)
                }
            } else {
                NavigationLink(destination: NewMealView(date: date, tipo: tipo)) {
                    mealContent(nombre: nil, label: label)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func mealContent(nombre: String?, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let nombre = nombre, !nombre.isEmpty {
                Text(nombre)
                    .font(.subheadline)
                    .lineLimit(2)
            } else {
                Text("meal.add")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Helpers

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var dayHeader: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEE d"
        return formatter.string(from: date).capitalized
    }
}
