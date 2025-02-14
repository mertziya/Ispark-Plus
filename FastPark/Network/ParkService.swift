//
//  ParkService.swift
//  FastPark
//
//  Created by Mert Ziya on 10.02.2025.
//

import Foundation

class ParkService{
    
    static func fetchAllIsparks(completion : @escaping (Result<[Park],Error>) -> () ){
        guard let url = UrlEndpoints.getAllParksUrl else{ completion(.failure(ErrorTypes.urlError)) ; return}
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        session.dataTask(with: request) { data, _, error in
            if let error = error{
                completion(.failure(error))
                return
            }else if let data = data{
                do{
                    let allParks = try JSONDecoder().decode([Park].self, from: data)
                    completion(.success(allParks))
                }catch{
                    completion(.failure(error))
                }
            }else{
                completion(.failure(ErrorTypes.responseError))
                return
            }
        }.resume()
    }
    
    static func fetchParkDetails(parkID : Int , completion : @escaping (Result<ParkDetails,Error>) -> ()){
        guard let url = UrlEndpoints.getParkDetailsWith(id: parkID) else{completion(.failure(ErrorTypes.urlError)) ; return}
        let session = URLSession.shared
        let request = URLRequest(url: url)
        
        session.dataTask(with: request) { data, _, error in
            if let error = error{
                completion(.failure(error))
            }else if let data = data{
                do{
                    let detailsContainer = try JSONDecoder().decode([ParkDetails].self, from: data)
                    let details = detailsContainer.first!
                    completion(.success(details))
                }catch{
                    completion(.failure(error))
                }
            }else{
                completion(.failure(ErrorTypes.responseError))
            }
        }.resume()
    }
}



enum ErrorTypes: Error{
    case urlError
    case responseError
    case noParksError
}

extension ErrorTypes: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noParksError:
            return NSLocalizedString("There are no isparks nearby!", comment: "")
        default:
            return "Error"
        }
    }
}
