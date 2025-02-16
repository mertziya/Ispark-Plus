//
//  ParkMapView.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import Foundation
import MapKit
import CoreLocation

class ParkMapView : MKMapView, MKMapViewDelegate , CLLocationManagerDelegate{
    
    //Properties:
    private let locationManager = CLLocationManager()
    var hasCenteredOnUserLocation = false

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Create a single park annotation with the given parameters.
    func addParkAnnotation(to mapView: MKMapView, coordinate : CLLocationCoordinate2D, infoText : String, isOpen : Bool, fullness : CGFloat, parkID : Int) {
        let textWidth = getStringWidth(text: infoText, font: UIFont.systemFont(ofSize: 14))
        let annotation = ParkAnnotation(coordinate: coordinate, title: infoText, isOpen: isOpen, annotationFrame: CGRect(x: 0, y: 0, width: textWidth + 4, height: 20), fullness: fullness, parkID: parkID)

        mapView.addAnnotation(annotation)
    }
    
    // Decides how the point annotation should look
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil // Show default blue dot for user location
        }

        if let parkAnnotation = annotation as? ParkAnnotation {
            // Your custom ParkAnnotationView logic
            let identifier = "CustomParkAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ParkAnnotationView

            if annotationView == nil {
                annotationView = ParkAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }

            annotationView?.configure(with: parkAnnotation)
            return annotationView
        }

        // Handle other annotations (e.g., Searched Point Annotation)
        let defaultIdentifier = "DefaultPinAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: defaultIdentifier) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: defaultIdentifier)
            pinView?.pinTintColor = .red
            pinView?.canShowCallout = true
        } else {
            pinView?.annotation = annotation
        }

        return pinView
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
            
            addParkAnnotation(to: self, coordinate: coordinate, infoText: infoText, isOpen: isOpen, fullness: fullness, parkID: park.parkID ?? 0)
        }
        HapticFeedbackManager.heavyImpact()
    }
    
    // Removes all annotations from the map view:
    func clearAnnotations() {
        clearParkAnnotations()
    }
    
    func clearParkAnnotations() {
        let parkAnnotations = self.annotations.filter { $0 is ParkAnnotation }
        self.removeAnnotations(parkAnnotations)
    }
    
    func clearDefaultAnnotation() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.pointAnnotationCoordiante)
        let defaultAnnotation = self.annotations.filter { $0 is MKPointAnnotation }
        self.removeAnnotations(defaultAnnotation)
    }
    
    // Focuses on the map's given coordinate with the given zoom level:
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
    

    // Get User Location:
    
    func setupUserLocation() {

        self.delegate = self
        self.showsUserLocation = true // Show user's location on the map
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setPositionOnMap(){
        if let location = locationManager.location{
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            focusMap(latitude: lat, longitude: lng, zoomLevel: 0.75)
        }else{
            focusMap(latitude: 40.9793606, longitude: 29.0417213, zoomLevel: 0.75)
        }
    }
    

    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last?.coordinate {
            
            let locationDict: [String: Double] = [
                "latitude": userLocation.latitude,
                "longitude": userLocation.longitude
            ]
            
            UserDefaults.standard.set(locationDict, forKey: UserDefaults.Keys.userLocationCoordinate)

            // Center only the first time
            if !hasCenteredOnUserLocation {
                let region = MKCoordinateRegion(
                    center: userLocation,
                    latitudinalMeters: 5000,
                    longitudinalMeters: 5000
                )
                self.setRegion(region, animated: true)

                hasCenteredOnUserLocation = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
        focusMap(latitude: 40.9793606, longitude: 29.0417213, zoomLevel: 0.75)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            focusMap(latitude: 40.9793606, longitude: 29.0417213, zoomLevel: 0.75)
        default:
            break
        }

    }
    
    
    func createAnnotationForSearchedPoint(longitude: Double, latitude: Double) {
        
        clearDefaultAnnotation()

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Searched Location"

        self.addAnnotation(annotation)

        // Optionally zoom into the annotation
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.setRegion(region, animated: true)
        
        let locationDict: [String: Double] = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude
        ]
        UserDefaults.standard.set(locationDict, forKey: UserDefaults.Keys.pointAnnotationCoordiante)
    }
    
    
    // For handling adding pin from the main vc:
    
    
    func setupTapGesture() {
        self.alpha = 0.8
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        tapGesture.name = "mapTapGesture" //
        self.addGestureRecognizer(tapGesture)
    }

    

    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        let coordinate = self.convert(touchPoint, toCoordinateFrom: self)

        clearDefaultAnnotation()

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned Location"
        self.addAnnotation(annotation)

        let locationDict: [String: Double] = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude
        ]
        UserDefaults.standard.set(locationDict, forKey: UserDefaults.Keys.pointAnnotationCoordiante)
        
        removeTapGesture()
    }
    
    func removeTapGesture() {
        self.alpha = 1.0
        if let tapGesture = self.gestureRecognizers?.first(where: { $0.name == "mapTapGesture" }) {
            self.removeGestureRecognizer(tapGesture)
        }
    }
}
