//
//  LocationDetail.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import Foundation

struct ParkDetails : Codable{
    var locationName: String?
    var parkID: Int?
    var parkName, lat, lng: String?
    var capacity, emptyCapacity: Int?
    var updateDate, workHours, parkType: String?
    var freeTime, monthlyFee: Int?
    var tariff, district, address, areaPolygon: String?
    var date : Date?
}
