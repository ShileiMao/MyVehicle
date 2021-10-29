//
//  VehicleDetail.swift
//  My Vehicle
//
//  Created by Shilei Mao on 27/10/2021.
//

import Foundation

enum VehicleDetails: Codable {    
    case vehicleDetails(VehicleSumary)
    case sensorDetails(SensorDetailList)
    
    enum CodingKeys: String, CodingKey {
        case vehicleDetails
        case sensorDetails
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(VehicleSumary.self) {
            self = .vehicleDetails(value)
            return
        }
        
        if let value = try? container.decode(SensorDetailList.self) {
            self = .sensorDetails(value)
            return
        }
        
        throw DecodingError.typeMismatch(VehicleDetails.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Malformed JSON or wrong type for VehicleDetails"))
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .vehicleDetails(let vehicleSumary):
            try container.encode(vehicleSumary, forKey: .vehicleDetails)
        
        case .sensorDetails(let sensorDetailList):
            try container.encode(sensorDetailList.sensorDetails, forKey: .sensorDetails)
        }
    }
}

struct VehicleSumary: Codable {
    var vehicleID: String
    var name: String
    var reeferSerial: String
    var mobileNumber: String
    var customer: String
}
 


