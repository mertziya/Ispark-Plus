//
//  FavoritesTableViewCell.swift
//  FastPark
//
//  Created by Mert Ziya on 15.02.2025.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    // MARK: - Properties:
    static let reuseID : String = "FavoritesTableViewCellReuseID"
    static let nibName : String = "FavoritesTableViewCell"
    
    private var parkDetails : ParkDetails?

    // MARK: - UI Elements:
    @IBOutlet weak var deleteFavoriteButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var emptyPlacesLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var workhoursLabel: UILabel!
    @IBOutlet weak var isOpenedLabel: UILabel!
    
    // MARK: - Lifecycles:
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteFavoriteButton.isHidden = true
        deleteFavoriteButton.setTitle("", for: .normal)
        
        containerView.backgroundColor = .barBackground
        
        containerView.layer.cornerRadius = 12
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 4
        
        deleteFavoriteButton.isUserInteractionEnabled = true
        deleteFavoriteButton.addTarget(self, action: #selector(handleDeleteFavorites), for: .touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectionStyle = .none
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            containerView.alpha = 0.4 // highlighted color
        } else {
            containerView.alpha = 1.0 // Default color
        }
    }
    
    
    
    
    
}

// MARK: - Helper Functions:
extension FavoritesTableViewCell{
    func configureCell(_ details : ParkDetails){
        self.parkDetails = details
        
        parkNameLabel.text = details.parkName
        emptyPlacesLabel.text = "\(String(describing: details.emptyCapacity ?? 0)) \(NSLocalizedString("empty places", comment: ""))"
        lastUpdateLabel.text = getWhenDoesItSaved(details.updateDate)
        
        workhoursLabel.text = details.workHours
        configureIsOpenedLabel(workingHours: details.workHours)
    }
    
    func configureDeleteFavoritesButton(isEditing: Bool){
        deleteFavoriteButton.isHidden = !isEditing
    }
    
    @objc private func handleDeleteFavorites(){
        if let details = self.parkDetails{
            NotificationCenter.default.post(name: .favoritesUpdated, object: details)
        }else{
            print("DEBUG: NO PARK")
        }
    }
    
    private func getWhenDoesItSaved(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "nil" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent parsing

        guard let date = dateFormatter.date(from: dateString) else { return "Invalid date" }

        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: now)

        if let days = components.day, days > 0 {
            return "\(days) \(NSLocalizedString("days ago", comment: ""))"
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

        return NSLocalizedString("Just now", comment: "")
    }
    
    private func configureIsOpenedLabel(workingHours: String?) {
        guard let workingHours = workingHours else { return }

        if workingHours == "24 Saat" {
            isOpenedLabel.text = NSLocalizedString("Open", comment: "")
            isOpenedLabel.textColor = .systemGreen
            return
        }

        let timeComponents = workingHours.split(separator: "-").map { String($0) }
        guard timeComponents.count == 2 else {
            setClosedLabel()
            return
        }

        let calendar = Calendar.current
        let now = Date()

        guard let openingTime = getTimeOfToday(timeComponents[0]),
              let closingTime = getTimeOfToday(timeComponents[1]) else {
            setClosedLabel()
            return
        }

        // Handle cases where the closing time is after midnight (e.g., 22:00 - 03:00)
        let isOpened: Bool
        if closingTime < openingTime {
            // Spans midnight
            isOpened = now >= openingTime || now <= closingTime
        } else {
            isOpened = now >= openingTime && now <= closingTime
        }

        if isOpened {
            isOpenedLabel.text = NSLocalizedString("Open", comment: "")
            isOpenedLabel.textColor = .systemGreen
        } else {
            setClosedLabel()
        }
    }

    private func getTimeOfToday(_ timeString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let timeDate = dateFormatter.date(from: timeString) else { return nil }

        let calendar = Calendar.current
        let now = Date()

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)

        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        return calendar.date(from: components)
    }

    private func setClosedLabel() {
        isOpenedLabel.text = NSLocalizedString("Closed", comment: "")
        isOpenedLabel.textColor = .systemRed
    }

    
}
