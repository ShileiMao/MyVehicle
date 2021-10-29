//
//  TestVehicleInfoFetch.swift
//  My VehicleTests
//
//  Created by Shilei Mao on 29/10/2021.
//

import XCTest
@testable import MyVehicle
import CoreData

class TestVehicleInfoFetch: XCTestCase {
    var request: RetrieveVehilceInfo!
    var persistent: PersistenceController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        request = RetrieveVehilceInfo()
        persistent = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchInfo() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let expectation = expectation(description: "Test fake downloading")
        
        request.retrieveAllVehileConfig { vehicleConfig, error in
            if let error = error {
                XCTFail("Failed to download vehicle configurations: \(error.localizedDescription)")
                return
            }
            
            guard let _ = vehicleConfig else {
                XCTFail("Failed to parse vehicle config JSON, check your JSON decoder")
                return
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFetchAndStore() {
        let context = persistent.container.viewContext
        
        let expectation = expectation(description: "Test Vehicle downloading and passing")
        
        // create some fake managed objects in memory, otherwise the core data will not fetch the data with object definition not found exception
        let vehicle = Vehicle(context: context)
        vehicle.vehicleID = "1234"
        let user = User(context: context)
        user.userID = 3423
        let requestConfig = RequestConfig(context: context)
        requestConfig.vID = "1234"
        let sensor = Sensor(context: context)
        sensor.serialNumber = "324231"
        
        print("hdh")
        
        request.refresVehiclesFromServer(viewContext: context) { success, error in
            if let error = error {
                XCTFail("Failed to refresh vhicle info: \(error.localizedDescription)")
                return
            }
            guard success else {
                XCTFail("Failed to parse JSON")
                return
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
