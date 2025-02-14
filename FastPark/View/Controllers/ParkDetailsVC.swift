//
//  ParkDetailsVC.swift
//  FastPark
//
//  Created by Mert Ziya on 11.02.2025.
//

import UIKit

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
        
        let favoritesLabel = UILabel()
        favoritesLabel.text = NSLocalizedString("ADD", comment: "")
        favoritesLabel.textColor = .white
        favoritesLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        view.addSubview(closeButton)
        view.addSubview(addFavoritesButton)
        view.addSubview(directionsButton)
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
        directionsButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        directionsButton.layer.shadowRadius = 2
        directionsButton.layer.shadowOpacity = 0.5
        directionsButton.layer.shadowColor = UIColor.black.cgColor
        
        addFavoritesButton.setImage(UIImage(systemName: "star" , withConfiguration: configuration), for: .normal)
        addFavoritesButton.backgroundColor = #colorLiteral(red: 0.9157691598, green: 0.7833544016, blue: 0.263376832, alpha: 1)
        addFavoritesButton.tintColor = .white
        addFavoritesButton.layer.cornerRadius = 8
        //Shadow:
        addFavoritesButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addFavoritesButton.layer.shadowRadius = 2
        addFavoritesButton.layer.shadowOpacity = 0.5
        addFavoritesButton.layer.shadowColor = UIColor.black.cgColor
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addFavoritesButton.translatesAutoresizingMaskIntoConstraints = false
        directionsButton.translatesAutoresizingMaskIntoConstraints = false
        directionsLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
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
            
        ])
        
        directionsButton.addTarget(self, action: #selector(handleDirectionsClicked), for: .touchUpInside)
        addFavoritesButton.addTarget(self, action: #selector(handleAddFavoritesClicked), for: .touchUpInside)
        
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
        print("handle favorites clicked here!")
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
        }
        SearchHistoryService.saveAutopark(detail)
    }
}
