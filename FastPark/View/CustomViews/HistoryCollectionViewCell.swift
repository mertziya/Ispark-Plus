//
//  HistoryCollectionViewCell.swift
//  FastPark
//
//  Created by Mert Ziya on 13.02.2025.
//

import UIKit

class HistoryCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "HistoryCollectionViewCellID"
    static let nibName = "HistoryCollectionViewCell"

    @IBOutlet weak var districtNameLabel: UILabel!
    @IBOutlet weak var mahalleLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        
    }
    
    func configureLabelsWith(district : District){
        districtNameLabel.text = district.district
        if district.neighborhood == "-"{
            mahalleLabel.text = district.place
        }else{
            mahalleLabel.text = district.neighborhood
        }
        
        historyLabel.text = getWhenDoesItSaved(district.date)

    }
    
    func configureLabelsWith(parkDetails : ParkDetails){
        districtNameLabel.text = parkDetails.parkName
        mahalleLabel.text = parkDetails.workHours
        
        districtNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        mahalleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        historyLabel.text = getWhenDoesItSaved(parkDetails.date)
    }

    private func getWhenDoesItSaved(_ date: Date?) -> String {
        guard let date = date else { return "nil" }

        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: now)

        if let days = components.day, days > 0 {
            return "\(days) \(NSLocalizedString("days ago ", comment: ""))"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours) \(NSLocalizedString("hours ago", comment: ""))"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes) \(NSLocalizedString("minutes ago", comment: ""))"
        }
        if let seconds = components.second, seconds > 0 {
            return "\(seconds) \(NSLocalizedString("seconds ago", comment: ""))"
        }

        return "Just now"
    }
    
}
