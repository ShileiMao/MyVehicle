//
//  PersistentTest.swift
//  My VehicleTests
//
//  Created by Shilei Mao on 29/10/2021.
//

import XCTest
@testable import MyVehicle

class PersistentTest: XCTestCase {
    var persistent: PersistenceController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        persistent = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDataStore() throws {
        let context = persistent.container.viewContext
        for index in 0..<10 {
            let vehicle = Vehicle(context: context)
            vehicle.vehicleID = "\(index)"
            vehicle.name = "vehicle \(index)"
            vehicle.reeferSerial = "1234\(index)"
            vehicle.mobileNumber = "+353132432142"
        }
        do {
            try context.save()
            
            let persistence = VehiclePersistence(viewContext: context)
            let vehicles = try persistence.fetchDbObjects(filtParam: nil, keypath: \Vehicle.vehicleID)
            
            print("hello")
            XCTAssert(vehicles.count == 10, "Failed to test data insert")
            
        } catch let error {
            XCTFail("Failed to store the data: \(error.localizedDescription)")
        }
    }
    
    func testFetchData() {
        let context = persistent.container.viewContext
        
        do {
            try testDataStore()
            let persistence = VehiclePersistence(viewContext: context)
            let vehicles = try persistence.fetchDbObjects(filtParam: "1", keypath: \Vehicle.vehicleID)
            
            XCTAssert(vehicles.count == 1, "Failed to test data fetch, expected to have 2 values, found: \(vehicles.count)")
        } catch let error {
            XCTFail("Failed to fetch data: \(error.localizedDescription)")
        }
    }
    
    func testSensorPersistence() {
        let context = persistent.container.viewContext
        
        let testVehicleID = "007"
        let testVehilceName = "name 1"
        let testSensorName1 = "sensor 1"
        let testSensorName2 = "sensor 2"
        
        // vehicle info
        let vehicleSummary = VehicleSumary(vehicleID: testVehicleID, name: testVehilceName, reeferSerial: "4567", mobileNumber: "6789", customer: "87773")
        
        // sensor list
        let sensorDetail1 = SensorDetails(sensorZone: 1, sensorLocation: 2, serialNumber: "3456", macAddress: "7654", sensorName: testSensorName1, sensorType: .type1)
        let sensorDetail2 = SensorDetails(sensorZone: 2, sensorLocation: 2, serialNumber: "7890", macAddress: "6534", sensorName: testSensorName2, sensorType: .type2)
        
        let sensorDetail3 = SensorDetails(sensorZone: 2, sensorLocation: 2, serialNumber: "7891", macAddress: "6534", sensorName: testSensorName2, sensorType: .type2)
        
        do {
            
            // create one first otherwise the coredata will fail to fetch the data (won't happend for real world)
            let vehicle = Vehicle(context: context)
            vehicle.vehicleID = "0001"
            vehicle.name = "vehicle 0001"
            vehicle.reeferSerial = "12340001"
            vehicle.mobileNumber = "+353132432142"
            
            let fakeSensor1 = Sensor(context: context)
            fakeSensor1.serialNumber = "1234"
            fakeSensor1.sensorType = 1
            fakeSensor1.vehicle = vehicle
            
            try context.save()
            
            let persistence = VehiclePersistence(viewContext: context)
            try persistence.persistentVehicleDetails([vehicleSummary])
            
            let storedVehicles = try persistence.fetchDbObjects(filtParam: testVehicleID, keypath: \Vehicle.vehicleID)
            
            
            guard storedVehicles.count == 1 else {
                XCTFail("Failed to query stored vehicles, expecting 1, found: \(storedVehicles.count)")
                return
            }
            
            try persistence.persistSensorInfo([sensorDetail1, sensorDetail2], vehicleDetail: vehicleSummary)
            
            try persistence.persistSensorInfo([sensorDetail3], vehicleDetail: nil)
            
            let linkedSensors = storedVehicles.first!.vehicleSensors
            
            guard linkedSensors?.count == 2 else {
                XCTFail("Failed to link sensors to vehicle, expected 2, found: \(linkedSensors?.count ?? 0)")
                return
            }
            
            let allSensors = try persistence.fetchDbObjects(filtParam: nil, keypath: \Sensor.serialNumber)
            guard allSensors.count == 4 else {
                XCTFail("Failed to store / query sensor info, expected 4 sensors, found: \(allSensors.count)")
                return
            }
            
        } catch let error {
            XCTFail("Failed to test data persistent: \(error.localizedDescription)")
        }
    }

    func testRequestDetailsPersistence() {
        let context = persistent.container.viewContext

        let testRquestID1 = "1234t"
        let testRquestID2 = "12347"
        let testUserID1: Int64 = 43521
        
        // request details
        let requestDetail1 = RequestDetails(vID: testRquestID1, mobileAppID: 2345, messageType: 1)
        let requestDetail2 = RequestDetails(vID: testRquestID2, mobileAppID: 2345, messageType: 1)
        
        // user details
//        let userDetail = UserDetails(userID: testUserID1)
        
        
        do {
            let requestConfig = RequestConfig(context: context)
            requestConfig.vID = "1234"
            requestConfig.messageType = 1
            requestConfig.mobileAppID = 2
            
            let persistence = VehiclePersistence(viewContext: context)
            try persistence.persistentRequestDetails([requestDetail1, requestDetail2])
            let requests = try persistence.fetchDbObjects(filtParam: nil, keypath: \RequestConfig.vID)
            XCTAssert(requests.count == 3, "Failed to test the request detail fetch, expecting 3, found: \(requests.count)")
        } catch let error {
            XCTFail("Failed to store / fetch request details data: \(error.localizedDescription)")
        }
    }
    
    func testUserDetailPersistence() {
        let context = persistent.container.viewContext

        let testUserID1: Int64 = 43521
        let testUserID2: Int64 = 43523
        
        let vehicleID = "12344"
        
        // user details
        let userDetail1 = UserDetails(userID: testUserID1)
        let userDetail2 = UserDetails(userID: testUserID2)
        
        
        do {
            let vehicle = Vehicle(context: context)
            vehicle.vehicleID = vehicleID
            vehicle.name = "My vehicle"
            
            let user1 = User(context: context)
            user1.userID = 3322
            
            vehicle.addToVehicleUsers(user1)
            
            let persistence = VehiclePersistence(viewContext: context)
            try persistence.persistentUserDetails([userDetail1, userDetail2])
            
            let users = try persistence.fetchDbObjects(filtParam: nil, keypath: \User.userID)
            XCTAssert(users.count == 3, "Failed to test the user details fetch, expecting 3, found: \(users.count)")
            
            let linkedVehicles = user1.vehicles
            
            XCTAssert(linkedVehicles?.count == 1, "Failed to test user vehicle link")
            
        } catch let error {
            XCTFail("Failed to store / fetch request details data: \(error.localizedDescription)")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
