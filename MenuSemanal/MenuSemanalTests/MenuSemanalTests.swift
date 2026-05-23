//
//  MenuSemanalTests.swift
//  MenuSemanalTests
//

import XCTest
import CoreData
@testable import MenuSemanal

final class WeekNavigatorTests: XCTestCase {

    var navigator: WeekNavigator!

    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "es_ES")
        navigator = WeekNavigator(calendar: calendar)
    }

    func testInicialmenteEnSemanaActual() {
        XCTAssertEqual(navigator.currentWeekOffset, 0)
        XCTAssertTrue(navigator.isCurrentWeek)
    }

    func testSemanaActualTiene7Dias() {
        XCTAssertEqual(navigator.daysInWeek.count, 7)
    }

    func test4SemanasTiene28Dias() {
        XCTAssertEqual(navigator.daysIn4Weeks.count, 28)
    }

    func testAvanzarSemana() {
        navigator.goToNextWeek()
        XCTAssertEqual(navigator.currentWeekOffset, 1)
        XCTAssertFalse(navigator.isCurrentWeek)
    }

    func testRetrocederSemana() {
        navigator.goToPreviousWeek()
        XCTAssertEqual(navigator.currentWeekOffset, -1)
    }

    func testVolverASemanaActual() {
        navigator.goToNextWeek()
        navigator.goToCurrentWeek()
        XCTAssertTrue(navigator.isCurrentWeek)
    }

    func testAvanzar4Semanas() {
        navigator.goToNextMonth()
        XCTAssertEqual(navigator.currentWeekOffset, 4)
    }

    func testRetroceder4Semanas() {
        navigator.goToPreviousMonth()
        XCTAssertEqual(navigator.currentWeekOffset, -4)
    }

    func testWeekStartEsLunesEnCalendarioISO() {
        // Con calendario ISO, el inicio de semana debe ser lunes
        let calendar = Calendar(identifier: .iso8601)
        let nav = WeekNavigator(calendar: calendar)
        let weekday = calendar.component(.weekday, from: nav.weekStart)
        // En ISO8601, weekday 2 = lunes
        XCTAssertEqual(weekday, 2)
    }

    func testDiasConsecutivos() {
        let days = navigator.daysInWeek
        for i in 1..<days.count {
            let diff = Calendar.current.dateComponents([.day], from: days[i-1], to: days[i]).day!
            XCTAssertEqual(diff, 1)
        }
    }
}

// MARK: - Lógica de lista de la compra

final class ShoppingListTests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "MenuSemanal")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        context = container.viewContext
    }

    private func crearComida(nombre: String, tipo: String, fecha: Date, componentes: [(String, Bool)]) -> Comida {
        let comida = Comida(context: context)
        comida.id = UUID()
        comida.nombre = nombre
        comida.tipo = tipo
        comida.fecha = fecha
        for (nomComp, disponible) in componentes {
            let comp = Componente(context: context)
            comp.id = UUID()
            comp.nombre = nomComp
            comp.disponible = disponible
            comp.comida = comida
        }
        return comida
    }

    func testComponentesNoDisponiblesSonListaDeCompra() {
        let comida = crearComida(nombre: "Lentejas", tipo: "almuerzo", fecha: Date(), componentes: [
            ("Lentejas", true),
            ("Zanahorias", false),
            ("Chorizo", false),
        ])

        let noDisponibles = (comida.componentes as? Set<Componente>)?
            .filter { !$0.disponible }
            .compactMap { $0.nombre }
            .sorted() ?? []

        XCTAssertEqual(noDisponibles, ["Chorizo", "Zanahorias"])
    }

    func testComponentesDisponiblesNoAparecenEnListaDeCompra() {
        let comida = crearComida(nombre: "Paella", tipo: "almuerzo", fecha: Date(), componentes: [
            ("Arroz", true),
            ("Azafrán", true),
        ])

        let noDisponibles = (comida.componentes as? Set<Componente>)?
            .filter { !$0.disponible } ?? []

        XCTAssertTrue(noDisponibles.isEmpty)
    }

    func testComidaSinComponentesTieneListaVacia() {
        let comida = crearComida(nombre: "Bocadillo", tipo: "cena", fecha: Date(), componentes: [])
        let comps = (comida.componentes as? Set<Componente>) ?? []
        XCTAssertTrue(comps.isEmpty)
    }
}
