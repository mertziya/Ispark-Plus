//
//  ParkDetailsVC.swift
//  FastPark
//
//  Created by Mert Ziya on 11.02.2025.
//

import UIKit
import CoreLocation

class ParkDetailsVC: UIViewController {
    // MARK: - Properties:
    var parkID : Int?
    let mapVM = MapVM()
    var isOpened : Bool?
    var details : ParkDetails?
    
    // MARK: - UI Elements:
    private let scrollView = UIScrollView()
    private let contentView = DetailsContentView()
    private let loadingIndicator = UIActivityIndicatorView()
    
    private let closeButton = UIButton()
    private let directionsButton = UIButton()
    private let addFavoritesButton = UIButton()
    private let favoritesLabel = UILabel()
    
    private let distanceFromLocation = UILabel()
    private let distanceFromPin = UILabel()

    


    // MARK: - Lifecycles:
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVM.delegate = self
        mapVM.fetchParkDetails(with: parkID ?? 0)
        
        setupScrollView()
        setupViewUI()
        loadingView()
    
    }
    
    private func loadingView(){
        DispatchQueue.main.async {
            self.contentView.contentView.isHidden = true
            self.loadingIndicator.startAnimating()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.contentView.contentView.isHidden = false
            self.loadingIndicator.stopAnimating()
        }
    }

}

// MARK: - Scroll View:
extension ParkDetailsVC {
    private func setupScrollView() {
        // Add scrollView and contentView
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Set scrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor , constant: 100),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor , constant: 0),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Set width to match the screen, so it doesn't allow horizontal scrolling
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                    
            // MARK: - Scroll view's height
            contentView.heightAnchor.constraint(equalToConstant: 1080), // Adjust this
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .textfieldBackground
        view.backgroundColor = .textfieldBackground
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        loadingIndicator.style = .large
    }
}




// MARK: - UI Configurations for the top part of the view:
extension ParkDetailsVC{
    private func setupViewUI(){
        
        let directionsLabel = UILabel()
        directionsLabel.text = NSLocalizedString("GO", comment: "")
        directionsLabel.textColor = .white
        directionsLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        // Distance From the locations label configurations:
        let distancesStackView = UIStackView()
        distancesStackView.addArrangedSubview(distanceFromPin)
        distancesStackView.addArrangedSubview(distanceFromLocation)
        distancesStackView.axis = .vertical
        distancesStackView.spacing = 4

    
        view.addSubview(closeButton)
        view.addSubview(addFavoritesButton)
        view.addSubview(directionsButton)
        view.addSubview(distancesStackView)
        
        directionsButton.addSubview(directionsLabel)
        addFavoritesButton.addSubview(favoritesLabel)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        
        closeButton.setImage(UIImage(systemName: "xmark" , withConfiguration: configuration), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(handleCloseButtonClicked), for: .touchUpInside)
        
        directionsButton.setImage(UIImage(systemName: "car.side" , withConfiguration: configuration), for: .normal)
        directionsButton.backgroundColor = UIColor.link
        directionsButton.tintColor = .white
        directionsButton.layer.cornerRadius = 8
        //Shadow:
        directionsButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        directionsButton.layer.shadowRadius = 4
        directionsButton.layer.shadowOpacity = 0.5
        directionsButton.layer.shadowColor = UIColor.black.cgColor
                
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addFavoritesButton.translatesAutoresizingMaskIntoConstraints = false
        directionsButton.translatesAutoresizingMaskIntoConstraints = false
        directionsLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        distancesStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            
            directionsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            directionsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            directionsButton.heightAnchor.constraint(equalToConstant: 56),
            directionsButton.widthAnchor.constraint(equalToConstant: 56),
            
            addFavoritesButton.rightAnchor.constraint(equalTo: directionsButton.leftAnchor, constant: -20),
            addFavoritesButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            addFavoritesButton.heightAnchor.constraint(equalToConstant: 56),
            addFavoritesButton.widthAnchor.constraint(equalToConstant: 56),
            
            directionsLabel.centerXAnchor.constraint(equalTo: directionsButton.centerXAnchor),
            directionsLabel.bottomAnchor.constraint(equalTo: directionsButton.bottomAnchor, constant: 0),
            
            favoritesLabel.centerXAnchor.constraint(equalTo: addFavoritesButton.centerXAnchor),
            favoritesLabel.bottomAnchor.constraint(equalTo: addFavoritesButton.bottomAnchor, constant: 0),
            
            distancesStackView.rightAnchor.constraint(equalTo: addFavoritesButton.leftAnchor, constant: -8),
            distancesStackView.centerYAnchor.constraint(equalTo: directionsButton.centerYAnchor),
            distancesStackView.leftAnchor.constraint(equalTo: closeButton.rightAnchor, constant: 8),
            
        ])
        
        directionsButton.addTarget(self, action: #selector(handleDirectionsClicked), for: .touchUpInside)
        addFavoritesButton.addTarget(self, action: #selector(handleAddFavoritesClicked), for: .touchUpInside)
        
    }
    
    // MARK: - configure the distance from labels:
    
// Dictionary format:
//    let locationDict: [String: Double] = [
//        "latitude": userLocation.latitude,
//        "longitude": userLocation.longitude
//    ]
    
    
    private func setDistanceFromLocationLabelConfig(textMessage: String, label: UILabel, location: [String: Double]) {
        let lat = location["latitude"] ?? 0.0
        let lng = location["longitude"] ?? 0.0

        let parkLat = Double(self.details?.lat ?? "0.0") ?? 0.0
        let parkLng = Double(self.details?.lng ?? "0.0") ?? 0.0

        let startCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let endCoordinate = CLLocationCoordinate2D(latitude: parkLat, longitude: parkLng)

        let distance = distanceInKilometers(startCoordinate: startCoordinates, endCoordinate: endCoordinate)
        let distanceString = padString(distance)

        let distanceAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]

        let messageAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]

        let attributedText = NSMutableAttributedString(
            string: "\(distanceString) ",
            attributes: distanceAttributes
        )

        let messagePart = NSAttributedString(string: textMessage, attributes: messageAttributes)
        attributedText.append(messagePart)

        label.attributedText = attributedText
    }
    
    func padString(_ input: String) -> String {
        print(input.count)
        let requiredLength = 10
        if input.count >= requiredLength {
            return input
        } else {
            let paddingCount = requiredLength - input.count
            let padding = String(repeating: " ", count: paddingCount)
            return padding + input + padding
        }
    }
    
    private func distanceInKilometers(startCoordinate : CLLocationCoordinate2D , endCoordinate : CLLocationCoordinate2D) -> String{
        let startLocation = CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude)
        let endLocation = CLLocation(latitude: endCoordinate.latitude, longitude: endCoordinate.longitude)
        
        let distanceInMeters = startLocation.distance(from: endLocation)
        let distanceInKilometers = distanceInMeters / 1000.0

        return String(format: "%.2f km", distanceInKilometers)
    }
    
    
    private func addFavoritesUIConfig(){
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        
        if let details = details{
            if FavoritesService.isAlreadyInFavorites(details: details){
                addFavoritesButton.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                addFavoritesButton.tintColor = .white
                favoritesLabel.text = NSLocalizedString("REMOVE", comment: "")
                favoritesLabel.textColor = .white
                addFavoritesButton.setImage(UIImage(systemName: "minus" , withConfiguration: configuration), for: .normal)

            }else{
                addFavoritesButton.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                addFavoritesButton.tintColor = .white
                favoritesLabel.text = NSLocalizedString("ADD", comment: "")
                favoritesLabel.textColor = .white
                addFavoritesButton.setImage(UIImage(systemName: "plus" , withConfiguration: configuration), for: .normal)
            }
        }

        addFavoritesButton.layer.cornerRadius = 8
        //Shadow:
        addFavoritesButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        addFavoritesButton.layer.shadowRadius = 4
        addFavoritesButton.layer.shadowOpacity = 0.5
        addFavoritesButton.layer.shadowColor = UIColor.black.cgColor
        
        favoritesLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
}

// MARK: - Actions:
extension ParkDetailsVC{
    @objc private func handleCloseButtonClicked(){
        self.dismiss(animated: true)
    }
    
    @objc private func handleDirectionsClicked() {
        guard let details = self.details,
              let lat = details.lat,
              let lng = details.lng else {
            print("Invalid coordinates")
            return
        }
        
        Alerts.openMapsAlert(at: self, lat: lat, lng: lng)
    }
    

    @objc private func handleAddFavoritesClicked(){
        if let details = details{
            if FavoritesService.isAlreadyInFavorites(details: details){
                Alerts.confirmationAlert(on: self, title: NSLocalizedString("Remove from favoties", comment: " "), message: "") {
                    FavoritesService.removeFromFavorites(details)
                    HapticFeedbackManager.mediumImpact()

                    self.addFavoritesUIConfig()
                }
            }else{
                if FavoritesService.getFavorites().count >= 30{
                    Alerts.showErrorAlert(on: self,
                                          title: NSLocalizedString("Capacity Limit", comment: ""),
                                          message: NSLocalizedString("You can only add 30 objects to favorites", comment: ""))
                }else{
                    Alerts.confirmationAlert(on: self, title: NSLocalizedString("Add to favorites", comment: " "), message: "") {
                        FavoritesService.saveFavorite(details)
                        self.addFavoritesUIConfig()
                        HapticFeedbackManager.mediumImpact()
                    }
                }
            }
        }
    }
}


// MARK: - Data Binding:
extension ParkDetailsVC : MapVMDelegate{
    func isLoadingParks(isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading{
                self.contentView.isHidden = true
                self.loadingIndicator.startAnimating()
            }else{
                self.contentView.isHidden = false
                self.loadingIndicator.stopAnimating()
            }
        }
    }
        
    func didReturnWith(error: any Error) {} // Won't be used.
    
    func didFetchParks(with parks: [Park]) {} // Wont' be used.
    
    func didFetchParkDetails(with detail: ParkDetails) {
        self.details = detail
        DispatchQueue.main.async {
            self.contentView.configureDetails(details: detail)
            
            self.addFavoritesUIConfig() // handles the UI Configuration of add favorites Button.
            
            if let userLocationDict = UserDefaults.standard.dictionary(forKey: UserDefaults.Keys.userLocationCoordinate) as? [String : Double] {
                self.setDistanceFromLocationLabelConfig(textMessage: NSLocalizedString("away from you", comment: "") ,
                                                        label : self.distanceFromLocation ,
                                                   location: userLocationDict)
            }
            
            if let pointLocationDict = UserDefaults.standard.dictionary(forKey: UserDefaults.Keys.pointAnnotationCoordiante) as? [String : Double] {
                self.setDistanceFromLocationLabelConfig(textMessage: NSLocalizedString("away from pin", comment: "") ,
                                                        label : self.distanceFromPin ,
                                                   location: pointLocationDict)
            }

        }
        SearchHistoryService.saveAutopark(detail)
        
       
    }
}
