//
//  PriceListCell.swift
//  FastPark
//
//  Created by Mert Ziya on 12.02.2025.
//

import UIKit

class PriceListCell: UITableViewCell {
    
    static let reuseID = "priceListReuseID"
    static let nibName = "PriceListCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var parkTimeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureFields(priceList : PriceList){
        containerView.layer.cornerRadius = 12
        parkTimeLabel.text = priceList.timeRange
        priceLabel.text = priceList.price
    }
    
}
