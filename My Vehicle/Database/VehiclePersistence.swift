//
//  VehiclePersistence.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import Foundation
import CoreData

struct VehiclePersistence {
    var viewContext: NSManagedObjectContext
    
    /// Store the sensor infor list into the database, and link to the vehicle if any
    /// - Parameters:
    ///   - sensorDetails: list of `SensorDetails` object, wich all the baseic
    ///   - vehicleDetail: the object of Vehicle details,  if just want to add sensor without liking to any vehicle, send nil instead
    func persistSensorInfo(_ sensorDetails: [SensorDetails], vehicleDetail: VehicleSumary?) throws {
        do {
            var vehicle: Vehicle?
            
            if let vehicleDetail = vehicleDetail {
                let vehecles = try fetchDbObjects(filtParam: vehicleDetail.vehicleID, keypath: \Vehicle.vehicleID)
                if !vehecles.isEmpty {
                    vehicle = vehecles.first
                }
            }
            
            try persistentNewObjects(sensorDetails, objKeyPath: \SensorDetails.serialNumber, dbKeyPath: \Sensor.serialNumber) {
                newSensor, sensor in
                sensor.sensorZone = newSensor.sensorZone
                sensor.sensorLocation = newSensor.sensorLocation
                sensor.serialNumber = newSensor.serialNumber
                sensor.sensorName = newSensor.sensorName
                sensor.macAddress = newSensor.macAddress
                sensor.sensorType = newSensor.sensorType.rawValue
                
                vehicle?.addToVehicleSensors(sensor)
            }
        }
    }
    
    func persistentVehicleDetails(_ vehicleDetails: [VehicleSumary]) throws {
        do {
            try persistentNewObjects(vehicleDetails, objKeyPath: \VehicleSumary.vehicleID, dbKeyPath: \Vehicle.vehicleID, copyObject: { newVehicle, vehicle in
                vehicle.vehicleID = newVehicle.vehicleID
                vehicle.name = newVehicle.name
                vehicle.reeferSerial = newVehicle.reeferSerial
                vehicle.customer = newVehicle.customer
                vehicle.mobileNumber = newVehicle.mobileNumber
            })
        }
    }
    
    func persistentRequestDetails(_ requestDetails: [RequestDetails]) throws {
        do {
            try persistentNewObjects(requestDetails, objKeyPath: \RequestDetails.vID, dbKeyPath: \RequestConfig.vID, copyObject: { newObjct, dbObject in
                dbObject.vID = newObjct.vID
                dbObject.mobileAppID = newObjct.mobileAppID
                dbObject.messageType = newObjct.messageType
            })
        }
    }
    
    func persistentUserDetails(_ userDetails: [UserDetails]) throws {
        do {
            try persistentNewObjects1(userDetails, objKeyPath: \UserDetails.userID, dbKeyPath: \User.userID, copyObject: { newObjct, dbObject in
                dbObject.userID = newObjct.userID
            })
        }
    }
    
    func fetchDbObjects<T: NSManagedObject, Value>(filtParam: String? = nil, keypath: KeyPath<T, Value>) throws -> [T] {
        guard let name = T.entity().name else {
            throw DbError.illegalParam(message: "Wrong managed object provided")
        }
        let fetchRequest = NSFetchRequest<T>(entityName: name)
        if let filtParam = filtParam {
            let paramName = NSExpression(forKeyPath: keypath).keyPath
            fetchRequest.predicate = NSPredicate(format: "\(paramName) = %@", filtParam)
        }
        
        do {
            let objects = try viewContext.fetch(fetchRequest)
            return objects
        }
    }
    
    func persistentNewObjects<T: Codable, K: NSManagedObject, Value: Equatable>(_ objects: [T], objKeyPath: KeyPath<T, Value>, dbKeyPath: KeyPath<K, Value?>, copyObject: (_ newObjct: T, _ dbObject: K) -> Void) throws {
        
        do {
            let existingObjects = try fetchDbObjects(filtParam: nil, keypath: dbKeyPath)
            
            let newObjects = objects.filter { newObject in
                !existingObjects.contains(where: { dbObject in
                    dbObject[keyPath: dbKeyPath] == newObject[keyPath: objKeyPath]
                })
            }
            
            for newObject in newObjects {
                let dbObject = K(context: viewContext)
                copyObject(newObject, dbObject)
            }
            
            try viewContext.save()
        }
    }
    
    func persistentNewObjects1<T: Codable, K: NSManagedObject, Value: Equatable>(_ objects: [T], objKeyPath: KeyPath<T, Value>, dbKeyPath: KeyPath<K, Value>, copyObject: (_ newObjct: T, _ dbObject: K) -> Void) throws {
        
        do {
            let existingObjects = try fetchDbObjects(filtParam: nil, keypath: dbKeyPath)
            
            let newObjects = objects.filter { newObject in
                !existingObjects.contains(where: { dbObject in
                    dbObject[keyPath: dbKeyPath] == newObject[keyPath: objKeyPath]
                })
            }
            
            for newObject in newObjects {
                let dbObject = K(context: viewContext)
                copyObject(newObject, dbObject)
            }
            
            try viewContext.save()
        }
    }
}
