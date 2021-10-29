//
//  DbError.swift
//  MyVehicle
//
//  Created by Shilei Mao on 29/10/2021.
//

import Foundation

enum DbError: Error {
    case illegalParam(message: String)
    case unexpectedError(message: String)
}
