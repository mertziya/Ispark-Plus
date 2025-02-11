//
//  ParkMapView.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import Foundation
import MapKit

class ParkMapView : MKMapView, MKMapViewDelegate{
    
    //Properties:
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Create a single park annotation with the given parameters.
    func addParkAnnotation(to mapView: MKMapView, coordinate : CLLocationCoordinate2D, infoText : String, isOpen : Bool, fullness : CGFloat) {
        let textWidth = getStringWidth(text: infoText, font: UIFont.systemFont(ofSize: 14))
        let annotation = ParkAnnotation(coordinate: coordinate, title: infoText, isOpen: isOpen, annotationFrame: CGRect(x: 0, y: 0, width: textWidth + 4, height: 20), fullness: fullness)

        mapView.addAnnotation(annotation)
    }
    
    // Decides how the point annotation should look
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil  // Don't customize user's location annotation
        }

        let identifier = "CustomParkAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ParkAnnotationView

        if annotationView == nil {
            annotationView = ParkAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }

        if let parkAnnotation = annotation as? ParkAnnotation {
            annotationView?.configure(with: parkAnnotation)
        }

        return annotationView
    }
    
    // Configures the map annotation points:
    func configureAnnotations(parks : [Park]){
        for park in parks{
            let isOpen = park.isOpen == 1 ? true : false
            
            let lat = CLLocationDegrees(park.lat ?? "0") ?? 0.0
            let lng = CLLocationDegrees(park.lng ?? "0") ?? 0.0
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            var infoText : String = ""
            var fullness : CGFloat = 0.0
            
            if isOpen{
                fullness = CGFloat( (park.capacity ?? 0) - (park.emptyCapacity ?? 0) ) / CGFloat(park.capacity ?? 1)
                infoText = "\( (park.capacity ?? 0) - (park.emptyCapacity ?? 0) ) / \(park.capacity ?? 0)"
            }else{
                infoText = "KAPALI"
            }
            
            addParkAnnotation(to: self, coordinate: coordinate, infoText: infoText, isOpen: isOpen, fullness: fullness)
        }
    }
    
    func focusMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoomLevel: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.setRegion(region, animated: true)
    }
    
    // Helper Function to get the string's text width:
    func getStringWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
}
