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
}

class MapVM{
    static let shared = MapVM()

    weak var delegate : MapVMDelegate?
    
    func fetchAllParks(){
        delegate?.isLoadingParks(isLoading: true)
        DispatchQueue.global().asyncAfter(deadline: .now()+0.5) {
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
    
}
