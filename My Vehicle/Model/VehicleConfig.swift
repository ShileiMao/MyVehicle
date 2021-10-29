//
//  VehicleConfig.swift
//  My Vehicle
//
//  Created by Shilei Mao on 27/10/2021.
//

import Foundation

struct VehicleConfig: Codable {
    var vehicleDetails: [VehicleDetails]
    var requestDetails: [RequestDetails]
    var userDetails: [UserDetails]
}
