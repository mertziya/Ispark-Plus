//
//  SearchListCell.swift
//  FastPark
//
//  Created by Mert Ziya on 14.02.2025.
//

import UIKit

class SearchListCell: UITableViewCell {
    
    static let reuseID = "SearchListCellReuseID"
    static let nibName = "SearchListCell"
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var neighbourhoodNameLabel: UILabel!
    @IBOutlet weak var districtNameLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        stackView.layer.cornerRadius = 12
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureSearchCellWith(_ district : District){
        placeNameLabel.text = district.place?.lowercased().capitalized
        neighbourhoodNameLabel.text = district.neighborhood?.lowercased().capitalized
        districtNameLabel.text = district.district
    }
    
}
