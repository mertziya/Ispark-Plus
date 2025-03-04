//
//  UrlEndpoints.swift
//  FastPark
//
//  Created by Mert Ziya on 10.02.2025.
//

import Foundation

class UrlEndpoints{
    static let getAllParksUrl = URL(string: "https://api.ibb.gov.tr/ispark/Park")
    static func getParkDetailsWith(id : Int) -> URL?{
        return URL(string: "https://api.ibb.gov.tr/ispark/ParkDetay?id=\(id)")
    }
}
