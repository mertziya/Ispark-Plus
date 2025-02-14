//
//  SearchVm.swift
//  FastPark
//
//  Created by Mert Ziya on 13.02.2025.
//

import Foundation
import MapKit


protocol SearchVMDelegate : AnyObject{
    func didReturnDistricts(districts : [District])
    func didReturnWithError(error: Error)
}

class SearchVM{
    
    weak var delegate : SearchVMDelegate?
    
    func fetchDistricts(query : String) {
        
        fetchDistrictsContaining(query: query) { districts in
            var allDistricts: [District] = [] // You can also define it inside the closure
            allDistricts.append(contentsOf: districts)
            allDistricts.append(contentsOf: self.fetchBuiltinDistrictsContaining(query: query))
            
            self.delegate?.didReturnDistricts(districts: allDistricts)
        }

    }
    
    func fetchDistrictsContaining(query: String, completion: @escaping ([District]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.9900, longitude: 29.0286), // Kadıköy area
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Covers most of Istanbul
        )
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                completion([]) // Return empty array on error
            } else if let response = response {
                var searchedResults: [District] = []

                print("Number of results: \(response.mapItems.count)")
                for item in response.mapItems {
                    
                    var placeName = "noname"
                    if item.placemark.name != "" || item.placemark.name != nil{ placeName = item.placemark.name! }
                    if item.placemark.title != "" || item.placemark.name != nil{ placeName = item.placemark.title! }

                    
                    let searchedItem = District(
                        place: placeName,
                        district: item.placemark.locality ?? "-",
                        neighborhood: item.placemark.subLocality ?? "-",
                        lat: "\(item.placemark.coordinate.latitude)",
                        lng: "\(item.placemark.coordinate.longitude)"
                    )
                    searchedResults.append(searchedItem)
                }

//                print(searchedResults)
                completion(searchedResults)

            } else {
                print("DEBUG: ANOTHER searching error.")
                completion([]) // Return empty array for unexpected cases
            }
        }
    }
        
    func fetchBuiltinDistrictsContaining(query: String) -> [District]{
        guard let url = Bundle.main.url(forResource: "ilceler", withExtension: "json") else {
            self.delegate?.didReturnWithError(error: ErrorTypes.urlError)
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let districts = try JSONDecoder().decode([District].self, from: data)

            let normalizedQuery = query.replacingTurkishCharacters().lowercased()

            let result = districts.filter { district in
                let normalizedNeighborhood = district.neighborhood?.normalizedForSearch().lowercased()
                let normalizedDistrict = district.district?.normalizedForSearch().lowercased()

                return normalizedNeighborhood!.contains(normalizedQuery) || normalizedDistrict!.contains(normalizedQuery)
            }

            return result
        } catch {
        }
        return []
    }
        
    
    
}
