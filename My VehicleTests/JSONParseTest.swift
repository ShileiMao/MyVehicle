//
//  JSONParseTest.swift
//  My VehicleTests
//
//  Created by Shilei Mao on 28/10/2021.
//

import XCTest
@testable import MyVehicle

class JSONParseTest: XCTestCase {
    var sampleJSON: String!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sampleJSON = """
        {
            "vehicleDetails": [
                {
                    "vehicleID": "11224455",
                    "name": "Vehicle Name 123",
                    "reeferSerial": "ABCD14DFSAS",
                    "mobileNumber": "+353891100111",
                    "customer": "Customer XYZ"
                },
                {
                    "sensorDetails": [
                        {
                            "sensorZone": 1,
                            "sensorLocation": 3,
                            "serialNumber": "DE:34:FE:23:3A",
                            "macAddress": "X000A3312T",
                            "sensorName": "Sensor 1",
                            "sensorType": 1
                        },
                        {
                            "sensorZone": 1,
                            "sensorLocation": 2,
                            "serialNumber": "3A:46:2A:A1:BB",
                            "macAddress": "X000A3417B",
                            "sensorName": "Sensor 2",
                            "sensorType": 2
                        },
                        {
                            "sensorZone": 2,
                            "sensorLocation": 3,
                            "serialNumber": "CE:2B:42:24:B3",
                            "macAddress": "X000A1617F",
                            "sensorName": "Sensor 3",
                            "sensorType": 1
                        },
                        {
                            "sensorZone": 3,
                            "sensorLocation": 2,
                            "serialNumber": "BE:4C:22:FV:BB",
                            "macAddress": "X000A1214E",
                            "sensorName": "Sensor 4",
                            "sensorType": 3
                        },
                        {
                            "sensorZone": 3,
                            "sensorLocation": 1,
                            "serialNumber": "3A:28:4A:A1:EE",
                            "macAddress": "X000A1254V",
                            "sensorName": "Sensor 5",
                            "sensorType": 2
                        }
                    ]
                }
            ],
            "requestDetails": [
                {
                    "vID": "1.1.1",
                    "mobileAppID": 4,
                    "messageType": 60
                }
            ],
            "userDetails": [
                {
                    "userID": 2210345
                }
            ]
        }
        """
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVehicleJSONParse() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let decoder = JSONDecoder()
        guard let jsonData = sampleJSON.data(using: .utf8) else {
            XCTFail("Failed to get sample json data")
            return
        }
        
        do {
            let vehicleConfig = try decoder.decode(VehicleConfig.self, from: jsonData)
            print("VehicleConfig: \(vehicleConfig)")
        } catch let error {
            XCTFail("Failed to decode json, error: \(error.localizedDescription)")
        }
    }
    
    func testVehicleJSONSerialize() throws {
        let encoder = JSONEncoder()
        
        let testVehicleID = "1234"
        let testVehilceName = "name 1"
        let testSensorName1 = "sensor 1"
        let testSensorName2 = "sensor 2"
        let testRquestID1 = "1234t"
        let testUserID1: Int64 = 43521
        
        // vehicle info
        let vehicleSummary = VehicleSumary(vehicleID: testVehicleID, name: testVehilceName, reeferSerial: "4567", mobileNumber: "6789", customer: "87773")
        
        // sensor list
        let sensorDetail1 = SensorDetails(sensorZone: 1, sensorLocation: 2, serialNumber: "3456", macAddress: "7654", sensorName: testSensorName1, sensorType: .type1)
        let sensorDetail2 = SensorDetails(sensorZone: 2, sensorLocation: 2, serialNumber: "7890", macAddress: "6534", sensorName: testSensorName2, sensorType: .type2)
        let sensorList = SensorDetailList(sensorDetails: [sensorDetail1, sensorDetail2])
        
        // vehicle detail
        let vehicleDetail = VehicleDetails.vehicleDetails(vehicleSummary)
        
        // sensor detail
        let sensorDetail = VehicleDetails.sensorDetails(sensorList)
        
        
        // request details
        let requestDetail = RequestDetails(vID: testRquestID1, mobileAppID: 2345, messageType: 1)
        
        // user details
        let userDetail = UserDetails(userID: testUserID1)
        
        let vehicleConfig = VehicleConfig(vehicleDetails: [vehicleDetail, sensorDetail], requestDetails: [requestDetail], userDetails: [userDetail])
        
        do {
            // encode the manually constructed vehicle configuration and compare with the JSONSerialization API
            // to see if they produce the same result
            let encoded = try encoder.encode(vehicleConfig)
            
            let json = String(data: encoded, encoding: .utf8) ?? ""
            print("Encoded json: \(json)")
            
            guard let decodedObject = try JSONSerialization.jsonObject(with: encoded, options: .fragmentsAllowed) as? [String: [Any]] else {
                XCTFail("Failed to deserialize encoded json")
                return
            }
            
            guard let vehicleConfig2 = decodedObject["vehicleDetails"] else {
                XCTFail("the serialised json not match the original one")
                return
            }
            
            guard let vehicleDetail2 = vehicleConfig2.first(where: {
                guard let dict = $0 as? [String: Any] else {
                    return false
                }
                guard dict.keys.contains("vehicleDetails") else {
                    return false
                }
                
                return true
            }) as? [String: Any] else {
                XCTFail("Failed to deserialize vehicle summary")
                return
            }
            
            guard let vehicleSummary2 = vehicleDetail2["vehicleDetails"] as? [String: Any],
                    let vehicleID = vehicleSummary2["vehicleID"] as? String,
                    vehicleID == testVehicleID else {
                XCTFail("Failed to compare the vehicleID")
                return
            }
            
            guard let sensorDetail2 = vehicleConfig2.first(where: {
                guard let dict = $0 as? [String: Any] else {
                    return false
                }
                
                guard dict.keys.contains("sensorDetails") else {
                    return false
                }
                
                return true
            }) as? [String: Any] else {
                XCTFail("Failed to deserialize sensor details")
                return
            }
            
            guard let sensorList2 = sensorDetail2["sensorDetails"] as? [[String: Any]], sensorList2.first!.keys.contains("sensorName") else {
                XCTFail("Failed to deserialize sensor list")
                return
            }
            print("Test sucess")
            
        } catch let error {
            XCTFail("Failed to encode vehicleConfig struct: \(error.localizedDescription)")
        }
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
