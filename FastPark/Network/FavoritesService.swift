//
//  FavoritesService.swift
//  FastPark
//
//  Created by Mert Ziya on 15.02.2025.
//

import Foundation
import UIKit


class FavoritesService{
    
    static let favoritesKey = "FavoritesKey"
    
    static func saveFavorite(_ parkDetail: ParkDetails) {
        var favorites = getFavorites()
    
        favorites.insert(parkDetail, at: 0)
        
        if let encodedData = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        }
    }
    
    static func getFavorites() -> [ParkDetails] {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
            let decoded = try? JSONDecoder().decode([ParkDetails].self, from: data) {
            return decoded
        }
        return []
    }
    
    static func isAlreadyInFavorites(details : ParkDetails) -> Bool{
        var favorites = getFavorites()
        for favorite in favorites{
            if favorite.parkID == details.parkID{
                return true
            }
        }
        return false
    }
    
    static func removeFromFavorites(_ details : ParkDetails){
        var favorites = getFavorites()
        
        favorites.removeAll { favorite in
            favorite.parkID == details.parkID
        }
        
        if let encodedData = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        }
    }
    
}
