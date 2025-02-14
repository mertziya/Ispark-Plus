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
        mahalleLabel.text = district.neighborhood
    }
    
    func configureLabelsWith(parkDetails : ParkDetails){
        districtNameLabel.text = parkDetails.parkName
        mahalleLabel.text = parkDetails.workHours
        
        districtNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        mahalleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }

}
