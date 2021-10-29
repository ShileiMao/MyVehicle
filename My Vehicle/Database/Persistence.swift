//
//  Persistence.swift
//  My Vehicle
//
//  Created by Shilei Mao on 27/10/2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController(inMemory: false)

    static var previewVehicle: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<10 {
            let vehicle = Vehicle(context: viewContext)
            vehicle.vehicleID = "\(index)"
            vehicle.name = "vehicle \(index)"
            vehicle.mobileNumber = "+353132432142"
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer
    
    /// Create persistent Controller, when testing, we specify the param inMemory to true, that will make sure all the data inserted into core data won't affect the data stored on device
    /// - Parameter inMemory: true if the data stores in memory, the data will be lost once the app restart.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MyVehicle")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
