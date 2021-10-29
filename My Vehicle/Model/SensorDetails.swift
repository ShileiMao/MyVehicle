//
//  SensorDetails.swift
//  My Vehicle
//
//  Created by Shilei Mao on 27/10/2021.
//

import Foundation

enum SensorType: Int64, Codable, CaseIterable, Identifiable {
    var id: Int64 {
        return self.rawValue
    }
    
    case type1 = 1
    case type2 = 2
    case type3 = 3
    
    
    /// Convert the sensor type to human redable strings
    /// - Returns: The human redable strings for sensor type
    func toReadableString() -> String {
        switch self {
        case .type1:
            return "Temperature"
        case .type2:
            return "Humidity"
        case .type3:
            return "Door"
        }
    }
}


struct SensorDetails: Codable {
    var sensorZone: Int64
    var sensorLocation: Int64
    var serialNumber: String
    var macAddress: String
    var sensorName: String
    var sensorType: SensorType
}

struct SensorDetailList: Codable {
    var sensorDetails: [SensorDetails]
}
