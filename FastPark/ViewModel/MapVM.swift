//
//  MapVM.swift
//  FastPark
//
//  Created by Mert Ziya on 10.02.2025.
//

import Foundation
import UIKit



protocol MapVMDelegate : AnyObject{
    func isLoadingParks(isLoading : Bool)
    func didReturnWith(error: Error)
    func didFetchParks(with parks: [Park])
    
    func didFetchParkDetails(with detail : ParkDetails)
}

class MapVM{

    weak var delegate : MapVMDelegate?
    
    func fetchAllParks(){
        delegate?.isLoadingParks(isLoading: true)
        DispatchQueue.global().async {
            ParkService.fetchAllIsparks { res in
                switch res{
                case .failure(let error):
                    self.delegate?.didReturnWith(error: error)
                case .success(let allParks):
                    self.delegate?.didFetchParks(with: allParks)
                }
            }
            self.delegate?.isLoadingParks(isLoading: false)
        }
    }
    
    func fetchParksWith(districtName : String){
        delegate?.isLoadingParks(isLoading: true)
        ParkService.fetchAllIsparks { res in
            switch res{
            case .failure(let error):
                self.delegate?.didReturnWith(error: error)
            case .success(let allParks):
                let parksWithDistrict = allParks.filter { park in
                    park.district?.normalizedForSearch() == districtName.normalizedForSearch()
                }
                if parksWithDistrict.count != 0{
                    self.delegate?.didFetchParks(with: parksWithDistrict)
                }else{
                    self.delegate?.didReturnWith(error: ErrorTypes.noParksError)
                }
            }
        }
        self.delegate?.isLoadingParks(isLoading: false)
    }
    
    func fetchAllParksWith(parkID : Int?){
        delegate?.isLoadingParks(isLoading: true)
        ParkService.fetchAllIsparks { res in
            switch res{
            case .failure(let error):
                self.delegate?.didReturnWith(error: error)
            case .success(let allParks):
                let parksThatHaveID = allParks.filter { park in
                    park.parkID == parkID
                }
                if parksThatHaveID.count != 0{
                    self.delegate?.didFetchParks(with: parksThatHaveID)
                }else{
                    self.delegate?.didReturnWith(error: ErrorTypes.noParksError)
                }
            }
        }
        delegate?.isLoadingParks(isLoading: false)
    }

    
    
    func fetchParkDetails(with parkID : Int){
        delegate?.isLoadingParks(isLoading: true)
        DispatchQueue.global().async {
            ParkService.fetchParkDetails(parkID: parkID) { res in
                switch res{
                case .failure(let error):
                    self.delegate?.didReturnWith(error: error)
                case .success(let details):
                    self.delegate?.didFetchParkDetails(with: details)
                }
            }
            self.delegate?.isLoadingParks(isLoading: false)
        }
    }
    
    
}



extension String {
    func normalizedForSearch() -> String {
       self.replacingTurkishCharacters().lowercased()
   }

    func replacingTurkishCharacters() -> String {
        let replacements: [String: String] = [
            "Ğ": "g", "ğ": "g",
            "Ü": "u", "ü": "u",
            "Ş": "s", "ş": "s",
            "İ": "i", "i": "i",
            "ı": "i",
            "Ö": "o", "ö": "o",
            "Ç": "c", "ç": "c"
        ]

        var newString = self
        for (original, replacement) in replacements {
            newString = newString.replacingOccurrences(of: original, with: replacement)
        }

        return newString
    }
}
