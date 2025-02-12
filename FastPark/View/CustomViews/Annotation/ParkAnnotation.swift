//
//  ParkAnnotation.swift
//  FastPark
//
//  Created by Mert Ziya on 10.02.2025.
//

import Foundation

import MapKit

class ParkAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var isOpen : Bool?
    var fullness : CGFloat?
    var annotationFrame : CGRect?
    var parkID : Int?

    init(coordinate: CLLocationCoordinate2D, title: String, isOpen : Bool , annotationFrame: CGRect, fullness: CGFloat, parkID: Int) {
        self.coordinate = coordinate
        self.title = title
        self.isOpen = isOpen
        self.annotationFrame = annotationFrame
        self.fullness = fullness
        self.parkID = parkID
    }
}
