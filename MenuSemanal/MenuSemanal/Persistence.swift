//
//  Persistence.swift
//  MenuSemanal
//
//  Created by Ion Jaureguialzo Sarasola on 23/05/2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        let tiposComida = ["almuerzo", "cena"]
        let nombres = [
            ["almuerzo": "Lentejas", "cena": "Tortilla de patatas"],
            ["almuerzo": "Paella", "cena": "Ensalada"],
            ["almuerzo": "Macarrones", "cena": "Sopa de verduras"],
            ["almuerzo": "Pollo al horno", "cena": "Gazpacho"],
            ["almuerzo": "Merluza", "cena": "Croquetas"],
            ["almuerzo": "Cocido", "cena": "Pizza casera"],
            ["almuerzo": "Cordero", "cena": "Revuelto de setas"],
        ]

        for dayOffset in 0..<7 {
            guard let fecha = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            let nombresDelDia = nombres[dayOffset]

            for tipo in tiposComida {
                let comida = Comida(context: viewContext)
                comida.id = UUID()
                comida.fecha = fecha
                comida.tipo = tipo
                comida.nombre = nombresDelDia[tipo] ?? ""

                let comp1 = Componente(context: viewContext)
                comp1.id = UUID()
                comp1.nombre = "Ingrediente A"
                comp1.disponible = true
                comp1.comida = comida

                let comp2 = Componente(context: viewContext)
                comp2.id = UUID()
                comp2.nombre = "Ingrediente B"
                comp2.disponible = false
                comp2.comida = comida
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MenuSemanal")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
