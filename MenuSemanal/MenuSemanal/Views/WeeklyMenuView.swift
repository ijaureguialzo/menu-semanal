//
//  WeeklyMenuView.swift
//  MenuSemanal
//

import SwiftUI
import CoreData

struct WeeklyMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var navigator = WeekNavigator()

    // Detectamos iPad
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool { horizontalSizeClass == .regular }

    var body: some View {
        NavigationStack {
            Group {
                if isIPad {
                    fourWeeksView
                } else {
                    oneWeekView
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !navigator.isCurrentWeek {
                        Button(String(localized: "nav.today")) {
                            withAnimation { navigator.goToCurrentWeek() }
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            withAnimation { isIPad ? navigator.goToNextMonth() : navigator.goToNextWeek() }
                        } else {
                            withAnimation { isIPad ? navigator.goToPreviousMonth() : navigator.goToPreviousWeek() }
                        }
                    }
            )
        }
    }

    // MARK: - Subvistas

    private var oneWeekView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(navigator.daysInWeek, id: \.self) { date in
                    DayMenuView(date: date)
                }
            }
            .padding()
        }
    }

    private var fourWeeksView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Cabeceras de días
                ForEach(weekdayHeaders, id: \.self) { header in
                    Text(header)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                ForEach(navigator.daysIn4Weeks, id: \.self) { date in
                    DayMenuView(date: date, compact: true)
                }
            }
            .padding()
        }
    }

    private var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = .current
        // Obtener los 7 días de la semana actual para extraer los nombres
        return navigator.daysInWeek.map { date in
            formatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
        }
    }

    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        if isIPad {
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: navigator.weekStart).capitalized
        } else {
            // Mostrar rango de la semana
            let start = navigator.weekStart
            let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
            let startStr = DateFormatter.localizedString(from: start, dateStyle: .short, timeStyle: .none)
            let endStr = DateFormatter.localizedString(from: end, dateStyle: .short, timeStyle: .none)
            return "\(startStr) – \(endStr)"
        }
    }
}

#Preview {
    WeeklyMenuView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
