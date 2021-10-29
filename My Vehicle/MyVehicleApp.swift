//
//  MyVehicleApp.swift
//  My Vehicle
//
//  Created by Shilei Mao on 27/10/2021.
//

import SwiftUI

@main
struct MyVehicleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            VehicleList()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
