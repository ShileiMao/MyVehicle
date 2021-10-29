//
//  RetrieveVehicleInfo.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import Foundation
import CoreData

struct RetrieveVehilceInfo {
    func refresVehiclesFromServer(viewContext: NSManagedObjectContext, callback: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        retrieveAllVehileConfig { vehicleConfig, error in
            var success = false
            var respErr: Error? = error
            
            defer {
                callback(success, respErr)
            }
            
            guard let vehicleConfig = vehicleConfig else {
                return
            }
            
            // get the objects from JSON
            let vehicleDetails = vehicleConfig.vehicleDetails
            let requestDetails = vehicleConfig.requestDetails
            let userDetails = vehicleConfig.userDetails
            
            // initialise persistence helper
            let persistence = VehiclePersistence(viewContext: viewContext)
            
            // search for the vehicle summary, we are using this add the relationship with the sensors
            let vehicleSummary = vehicleDetails.map { item -> VehicleSumary? in
                switch item {
                case .vehicleDetails(let summary):
                    return summary
                default:
                    return nil
                }
            }
                .first(where: { $0 != nil })
            
            guard let vehicleSummary = vehicleSummary else {
                success = false
                respErr = DbError.unexpectedError(message: "Unable to find vehicle information, check the data from your server")
                return
            }

            // store the data from server (currently fake from local environment)
            do {
                for vehicleDetail in vehicleDetails {
                    switch vehicleDetail {
                    case .vehicleDetails(let vehicleSumary):
                        try persistence.persistentVehicleDetails([vehicleSumary])
                        
                    case .sensorDetails(let sensorDetailList):
                        try persistence.persistSensorInfo(sensorDetailList.sensorDetails, vehicleDetail: vehicleSummary)
                    }
                }
                
                try persistence.persistentUserDetails(userDetails)
                try persistence.persistentRequestDetails(requestDetails)
                
                success = true
            } catch let error {
                print("Failed to persistent data: \(error.localizedDescription)")
                success = false
                respErr = error
            }
        }
    }
    
    func retrieveAllVehileConfig(_ callback: @escaping (_ vehicleConfig: VehicleConfig?, _ error: Error?) -> Void) {
        if let path = Bundle.main.path(forResource: "SampleVehicleConfig", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonDecoder = JSONDecoder()
                let vehicleConfig = try jsonDecoder.decode(VehicleConfig.self, from: data)
                
                callback(vehicleConfig, nil)
            } catch let error {
                callback(nil, error)
            }
        }
    }
}
