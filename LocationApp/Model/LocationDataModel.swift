//
//  LocationModel.swift
//  LocationTracker
//
//  Created by Partha Pratim on 28/12/23.
//

import Foundation

// MARK: - ImageDataModel
struct LocationDataModel: Codable {
    var payload: [Payload]?
}

// MARK: - Datum
struct Payload: Codable {
    let latitude, longitude, address, message: String?

    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
        case address = "address"
        case message = "message"
    }
}
