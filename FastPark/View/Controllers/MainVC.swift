//
//  ViewController.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import UIKit
import MapKit
import CoreLocation

class MainVC: UIViewController {
    
    // MARK: - Properties:
    let mapVM = MapVM()
    
    private var sidebarVC: SideBarVC? // For handling the sidebar functionality, this child view controller is used.
    
    // MARK: - UI Elements:
    var mapView = ParkMapView()
    
    private var searchIcon = UIButton()
    private var hideIcon = UIButton()

    // MARK: - Lifecycles:
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVM.delegate = self
        
        setupUIConstraints()
        setupUIDesignandFunction()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePresentationExpanded), name: .presentatonExpanded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePresentationShrinked), name: .presentationShrinked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSideBar), name: .menuButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSidebar), name: .shouldHideSideBar, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAnnotationClick(_:)), name: .annotationClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDistrictSelected(_:)), name: .districtSelected, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSearchBar()
        DispatchQueue.main.async {
            self.mapView.setupUserLocation()
            self.mapView.setPositionOnMap()
        }
        
    }
                                               
    deinit {
        NotificationCenter.default.removeObserver(self, name: .presentatonExpanded, object: nil)
        NotificationCenter.default.removeObserver(self, name: .presentationShrinked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .menuButtonTapped, object: nil)
        NotificationCenter.default.removeObserver(self, name: .shouldHideSideBar, object: nil)
        NotificationCenter.default.removeObserver(self, name: .annotationClicked, object: nil)
    }
}



// MARK: - UI Config:
extension MainVC : UIViewControllerTransitioningDelegate{
    
    private func setupUIConstraints(){
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(searchIcon)
        view.addSubview(hideIcon)
                
        mapView.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        hideIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            searchIcon.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            searchIcon.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -136),
            searchIcon.heightAnchor.constraint(equalToConstant: 36),
            searchIcon.widthAnchor.constraint(equalToConstant: 128),
            
            hideIcon.bottomAnchor.constraint(equalTo: searchIcon.topAnchor, constant: -16),
            hideIcon.centerXAnchor.constraint(equalTo: searchIcon.centerXAnchor),
            hideIcon.heightAnchor.constraint(equalToConstant: 32),
            hideIcon.widthAnchor.constraint(equalToConstant: 128),
            
        ])
    }
    
    private func setupUIDesignandFunction(){
        mapView.isUserInteractionEnabled = true

        // Hides the sidebar when the map is clicked.
        let mapTappedGesture = UITapGestureRecognizer(target: self, action: #selector(hideSidebar))
        mapView.addGestureRecognizer(mapTappedGesture)
        
        // configure search icon:
        searchIcon.backgroundColor = .link
        searchIcon.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchIcon.setTitle(NSLocalizedString("Search All", comment: ""), for: .normal)
        searchIcon.setTitleColor(.textfieldBackground, for: .normal)
        searchIcon.tintColor = .textfieldBackground
        searchIcon.layer.cornerRadius = 32 / 2
        
        searchIcon.layer.shadowColor = UIColor.black.cgColor
        searchIcon.layer.shadowOffset = CGSize(width: 2, height: 2) // Controls the direction
        searchIcon.layer.shadowOpacity = 1.0 // Adjust the visibility
        searchIcon.layer.shadowRadius = 6 // Controls the blur
        
        searchIcon.addTarget(self, action: #selector(handleSearchIconTapped), for: .touchUpInside)
        
        
        // Configure Hide Icon:
        hideIcon.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
        hideIcon.setTitleColor(.textfieldBackground, for: .normal)
        hideIcon.backgroundColor = .logo
        hideIcon.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        hideIcon.tintColor = .textfieldBackground
        hideIcon.layer.cornerRadius = 32 / 2
        
        hideIcon.layer.shadowColor = UIColor.black.cgColor
        hideIcon.layer.shadowOffset = CGSize(width: 2, height: 2) // Controls the direction
        hideIcon.layer.shadowOpacity = 1.0 // Adjust the visibility
        hideIcon.layer.shadowRadius = 6 // Controls the blur
        
        hideIcon.addTarget(self, action: #selector(handleHideButton), for: .touchUpInside)
        
    }
    
    private func presentSearchBar() {
        let searchVC = SearchVC()
        searchVC.modalPresentationStyle = .custom
        searchVC.transitioningDelegate = self // Assign transitioning delegate
        
        self.definesPresentationContext = true
        self.present(searchVC, animated: true)
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SearchVCPresentation(presentedViewController: presented, presenting: presenting)
    }
}




// MARK: - Actions:
extension MainVC{
    
    @objc private func showSideBar(_ gesture : UIGestureRecognizer){
        toggleSidebar()
    }
    
    @objc private func hideSidebar() {
        view.endEditing(true)
        guard let sidebar = sidebarVC else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.mapView.alpha = 1
            sidebar.view.frame.origin.x = self.view.frame.width
        }) { _ in
            sidebar.view.removeFromSuperview()
            sidebar.removeFromParent()
            self.sidebarVC = nil
        }
        NotificationCenter.default.post(name: .sideBarClosed, object: nil)
    }
    
    @objc private func handlePresentationExpanded(){
        // MARK: - Get Districts Search History Here:
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.mapView.alpha = 0.6
                
            }
        }
    }
    @objc private func handlePresentationShrinked(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.mapView.alpha = 1
            }
        }
    }
    
    @objc private func handleSearchIconTapped(){
        mapVM.fetchAllParks()
    }
    
    @objc private func handleHideButton(){
        DispatchQueue.main.async {
            self.mapView.clearAnnotations()
        }
    }
    
    @objc private func handleAnnotationClick(_ notification: Notification) {
        if let parkID = notification.object as? Int {
            presentParkDetailsVC(with: parkID)            
            
        } else {
            Alerts.showErrorAlert(on: self, title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Park doesn't exist", comment: ""))
        }
    }

    private func toggleSidebar() {
        let sidebar = SideBarVC()
        addToParentView(add: sidebar)
        
        // Animate appearance from right
        UIView.animate(withDuration: 0.3) {
            sidebar.view.frame.origin.x = self.view.frame.width - 340
            self.mapView.alpha = 0.6
        }

        sidebarVC = sidebar
    }
    
    private func addToParentView(add : UIViewController){
        addChild(add)
        add.view.frame = CGRect(x: view.frame.width, y: 0, width: 340, height: view.frame.height)
        view.addSubview(add.view)
        add.didMove(toParent: self)
    }
    
    private func presentParkDetailsVC(with parkID : Int){
        let parkDetailsVC = ParkDetailsVC()
        parkDetailsVC.parkID = parkID
        
        // Check if there's already a presented view controller
        if let presentedVC = self.presentedViewController {
            presentedVC.present(parkDetailsVC, animated: true)
        } else {
            self.present(parkDetailsVC, animated: true)
        }
    }
    
    @objc private func handleDistrictSelected(_ notification : Notification){
        self.mapView.alpha = 1
        if let district = notification.object as? District{
            
            mapVM.fetchParksWith(districtName: district.district ?? "")
            DispatchQueue.main.async {
                self.mapView.focusMap(latitude: Double(district.lat!)!, longitude: Double(district.lng!)!, zoomLevel: 0.03)
            }
            SearchHistoryService.saveDistrict(district)
            
        }
    }
    
}

// MARK: - Map View Model
extension MainVC : MapVMDelegate{
    func isLoadingParks(isLoading: Bool) {
        DispatchQueue.main.async {
            isLoading ? LoadingView.showLoading(on: self , loadingMessage: NSLocalizedString("Autoparks are loading...", comment: "")) : LoadingView.hideLoading(from: self)
        }
    }
    
    func didReturnWith(error: any Error) {
        DispatchQueue.main.async {
            Alerts.showErrorAlert(on: self, title: NSLocalizedString("Warning", comment: ""), message: error.localizedDescription)
        }
    }
    
    func didFetchParks(with parks: [Park]) {
        DispatchQueue.main.async {
            self.mapView.clearAnnotations()
            self.mapView.configureAnnotations(parks: parks)
        }
    }
    
    func didFetchParkDetails(with detail: ParkDetails) {} // Won't be used
}
