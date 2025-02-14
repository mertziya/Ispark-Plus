//
//  SearchHistoryService.swift
//  FastPark
//
//  Created by Mert Ziya on 13.02.2025.
//

import Foundation



class SearchHistoryService{
    
    // MARK: - Search History Service for the Districts:
    static let DistrictHistoryKey = "DistrictsSearchHistory"
    
    static func saveDistrict(_ district: District) {
        var searchHistory = getSearchHistory()
        
        if searchHistory.count >= 30 {
            searchHistory.removeLast()
        }
        
        searchHistory.insert(district, at: 0)
        
        if let encodedData = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(encodedData, forKey: DistrictHistoryKey)
        }
    }

    static func getSearchHistory() -> [District] {
        if let data = UserDefaults.standard.data(forKey: DistrictHistoryKey),
           let decoded = try? JSONDecoder().decode([District].self, from: data) {
            return decoded
        }
        return []
    }
    
    static func clearDistrictHistory() {
        UserDefaults.standard.removeObject(forKey: DistrictHistoryKey)
    }
    
    
    
    // MARK: - Search History Service for the Autoparks:
    
    static let autoparksHistory = "autoparksHistory"
    
    static func saveAutopark(_ park: ParkDetails) {
        var searchHistory = getAutoparkHistory()

        // Remove the last element if we already have 20 items
        if searchHistory.count >= 30 {
            searchHistory.removeLast()
        }

        // Insert new park at the beginning
        searchHistory.insert(park, at: 0)

        // Encode and save back to UserDefaults
        if let encodedData = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(encodedData, forKey: autoparksHistory)
        }
    }

    static func getAutoparkHistory() -> [ParkDetails] {
        if let data = UserDefaults.standard.data(forKey: autoparksHistory),
           let decoded = try? JSONDecoder().decode([ParkDetails].self, from: data) {
            return decoded
        }
        return []
    }
    
    static func clearAutoParkSearchHistory() {
        UserDefaults.standard.removeObject(forKey: autoparksHistory)
    }
    
}
