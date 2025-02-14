//
//  DetailsContentView.swift
//  FastPark
//
//  Created by Mert Ziya on 12.02.2025.
//

import Foundation
import UIKit

class DetailsContentView : UIView{
    
    // MARK: - UI Elements:
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var autoparkNameLabel: UILabel!
    
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var fullnessLabel: UILabel!
    @IBOutlet weak var fullnessProgress: UIProgressView!
    
    @IBOutlet weak var workhoursLabel: UILabel!
    @IBOutlet weak var workHoursHours: UILabel!
    @IBOutlet weak var currentlyOpened: UILabel!
    
    
    @IBOutlet weak var parkTypeLabel: UILabel!
    @IBOutlet weak var ParkTypeType: UILabel!
    
    
    @IBOutlet weak var tarifestack: UIStackView!
    @IBOutlet weak var tarifeLabel: UILabel!
    @IBOutlet weak var tarifeTable: UITableView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var address: UILabel!
    
    
    @IBOutlet weak var coverView1: UIView!
    @IBOutlet weak var coverView2: UIView!
    @IBOutlet weak var coverView3: UIView!
    @IBOutlet weak var coverView4: UIView!
    
    
    // MARK: - Properties:
    private var priceList : [PriceList] = []{
        didSet{
            DispatchQueue.main.async {
                self.tarifeTable.reloadData()
            }
        }
    }
    
    //MARK: - Initializers:
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("DetailsContentView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        adjustCoverView(view: coverView1)
        adjustCoverView(view: coverView2)
        adjustCoverView(view: coverView3)
        adjustCoverView(view: coverView4)
        
    }
    
    func configureDetails(details : ParkDetails){
        autoparkNameLabel.text = details.parkName
        
        capacityLabel.text = NSLocalizedString("Capacity:", comment: "")
        updateTimeLabel.text = getUpdateTime(from: details.updateDate)
        fullnessLabel.text = getCapacityStringFrom(emptyCap: details.emptyCapacity, cap: details.capacity)
        setProgressView(emptyCap: details.emptyCapacity, cap: details.capacity)
        
        workhoursLabel.text = NSLocalizedString("Work Hours:", comment: "")
        workHoursHours.text = NSLocalizedString(details.workHours ?? "No Data", comment: "")
        setCurrentlyOpenedLabel(timeRange: details.workHours)
        
        parkTypeLabel.text = NSLocalizedString("Park Type:", comment: "")
        ParkTypeType.text = NSLocalizedString(details.parkType ?? "", comment: "")
        
        addressLabel.text = NSLocalizedString("Address:", comment: "")
        address.text = details.address ?? "No Data"
        
        tarifeLabel.text = NSLocalizedString("Price List:", comment: "")
        tarifeTable.delegate = self
        tarifeTable.dataSource = self
        tarifeTable.backgroundColor = .clear
        tarifeTable.register(UINib(nibName: PriceListCell.nibName, bundle: nil), forCellReuseIdentifier: PriceListCell.reuseID)
        
        setPriceList(monthlyFee: details.monthlyFee, tarife: details.tariff)
        
    }
    
}


// MARK: - Helper Functions for updating UI:
extension DetailsContentView : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tarifeTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tarifeTable.heightAnchor.constraint(equalToConstant: CGFloat(priceList.count * 36)),
            tarifestack.heightAnchor.constraint(equalToConstant: CGFloat(priceList.count * 36) + 60),
        ])
        
        return priceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tarifeTable.dequeueReusableCell(withIdentifier: PriceListCell.reuseID, for: indexPath) as? PriceListCell else{
            return UITableViewCell()
        }
        
        cell.configureFields(priceList: self.priceList[indexPath.row])
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }

    private func setPriceList(monthlyFee: Int?, tarife: String?) {
        var priceList: [PriceList] = []
        
        // Ensure tarife is not nil
        guard let tarife = tarife else { return }
        
        // Split by ';' to get each time range and price pair
        let elements = tarife.split(separator: ";")

        for element in elements {
            // Split each pair by ':' and trim whitespaces
            let parts = element.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            
            // Ensure the split resulted in exactly two parts
            if parts.count == 2 {
                let cleanPrice = String(parts[1].dropLast(3) + "₺")
                let priceEntry = PriceList(timeRange: NSLocalizedString(parts[0], comment: "") , price: cleanPrice)
                priceList.append(priceEntry)
            }
        }
        if monthlyFee != 0{
            let priceEntry = PriceList(timeRange: NSLocalizedString("Monthly", comment: ""), price: String(monthlyFee ?? 0) + "₺")
            priceList.append(priceEntry)
        }
        
        self.priceList = priceList
    }
    
    
    func getUpdateTime(from dateString: String?) -> String {
        if let dateString = dateString{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current

            guard let pastDate = formatter.date(from: dateString) else { return "No Data" }
            
            let now = Date()
            let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: pastDate, to: now)

            let day = diff.day != 0 ? "\(String(describing: diff.day ?? 0)) \(NSLocalizedString("Days ", comment: ""))" : ""
            let hour = diff.hour != 0 ? "\(String(describing: diff.hour ?? 0)) \(NSLocalizedString("Hours ", comment: ""))" : ""
            let minute = diff.minute != 0 ? "\(String(describing: diff.minute ?? 0)) \(NSLocalizedString("Minutes ", comment: ""))" : ""
            
            var updatedNow = ""
            if day == "" && hour == "" && minute == "" {updatedNow = NSLocalizedString("Updated Now", comment: "")}
            
            let updateTime = "\(NSLocalizedString("Last Update:", comment: "")) \(day)\(hour)\(minute)\(NSLocalizedString("ago", comment: ""))"
            
            if updatedNow == "" { return updateTime}
            else                { return updatedNow }
            
        }else{
            return "No Data"
        }
    }
    
    func getCapacityStringFrom(emptyCap : Int? , cap : Int?) -> String{
        if let emptyCap = emptyCap , let cap = cap{
            let fullCapacity = cap - emptyCap
            let returnString = "\(fullCapacity) / \(cap)"
            
            return returnString
        }else{
            return "No Data"
        }
    }
    
    func setProgressView(emptyCap : Int? , cap : Int?){
        if let emptyCap = emptyCap , let cap = cap{
            let fullCapacity = cap - emptyCap
            let percentage : Float = Float(fullCapacity) / Float(cap)
            self.fullnessProgress.progress = percentage
            self.fullnessProgress.transform = CGAffineTransform(scaleX: 1, y: 2) // Adjust Y scale
            
            self.fullnessProgress.trackTintColor = .systemBackground
            switch percentage{
            case 0...0.5:
                self.fullnessProgress.progressTintColor = .systemGreen
            case 0.5...0.7:
                self.fullnessProgress.progressTintColor = .systemYellow
            case 0.7...0.9:
                self.fullnessProgress.progressTintColor = .systemOrange
            case 0.9...1.0:
                self.fullnessProgress.progressTintColor = .systemRed
            default:
                break
            }
        }
    }
    
    func setCurrentlyOpenedLabel(timeRange: String?){
        
        //Handle 24 Hour opened Parks [ these types doesn't obey the other formats.]
        if timeRange == "24 Saat"{
            self.currentlyOpened.text = NSLocalizedString("Open", comment: "")
            self.currentlyOpened.textColor = .systemGreen
            return
        }
        
        guard let timeRange = timeRange else{return}
        var components = timeRange.components(separatedBy: "-")
        guard components.count == 2 else { return}
        
        // Convert "00:00" to "23:59"
        if components[1] == "00:00" {
            components[1] = "23:59"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let calendar = Calendar.current
        let now = Date()

        guard let startTime = formatter.date(from: components[0]),
             let endTime = formatter.date(from: components[1]) else { return}

        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)

        let nowMinutes = (nowComponents.hour ?? 0) * 60 + (nowComponents.minute ?? 0)
        let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
        let endMinutes = (endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0)

        
        
        let isOpened = (nowMinutes >= startMinutes && nowMinutes <= endMinutes)
        if isOpened{
            self.currentlyOpened.text = NSLocalizedString("Open", comment: "")
            self.currentlyOpened.textColor = .systemGreen
        }else{
            self.currentlyOpened.text = NSLocalizedString("Closed", comment: "")
            self.currentlyOpened.textColor = .systemRed
        }
    }
    
    private func adjustCoverView(view : UIView){
        view.layer.cornerRadius = 12
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        view.layer.shadowColor = UIColor.black.cgColor
    }
}


struct PriceList{
    var timeRange : String?
    var price : String?
}
