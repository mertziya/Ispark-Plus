//
//  Location.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import Foundation

struct Park : Codable {
    var parkID: Int?
    var parkName, lat, lng: String?
    var capacity, emptyCapacity: Int?
    var workHours, parkType: String?
    var freeTime: Int?
    var district: String?
    var isOpen: Int?
}

