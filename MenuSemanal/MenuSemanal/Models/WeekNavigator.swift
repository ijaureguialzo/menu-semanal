//
//  WeekNavigator.swift
//  MenuSemanal
//

import Foundation

/// Gestiona la navegación entre semanas. La primera semana empieza según la localización del dispositivo.
class WeekNavigator: ObservableObject {
    @Published var currentWeekOffset: Int = 0

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Fecha de inicio (lunes/domingo según localización) de la semana actual con offset.
    var weekStart: Date {
        let today = Date()
        let baseWeekStart = calendar.date(from: calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear], from: today
        ))!
        return calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: baseWeekStart)!
    }

    /// Fechas de los 7 días de la semana visible.
    var daysInWeek: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    /// Fechas de las 4 semanas visibles (para iPad).
    var daysIn4Weeks: [Date] {
        (0..<28).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    func goToNextWeek() {
        currentWeekOffset += 1
    }

    func goToPreviousWeek() {
        currentWeekOffset -= 1
    }

    func goToNextMonth() {
        currentWeekOffset += 4
    }

    func goToPreviousMonth() {
        currentWeekOffset -= 4
    }

    func goToCurrentWeek() {
        currentWeekOffset = 0
    }

    var isCurrentWeek: Bool {
        currentWeekOffset == 0
    }
}
