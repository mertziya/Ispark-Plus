//
//  ParkService.swift
//  FastPark
//
//  Created by Mert Ziya on 10.02.2025.
//

import Foundation

enum ErrorTypes: Error{
    case urlError
    case responseError
}

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
    
}


