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
    
    private var sidebarVC: SideBarVC? // For handling the sidebar functionality, this child view controller is used.
    
    // MARK: - UI Elements:
    private var mapView = ParkMapView()

    // MARK: - Lifecycles:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIConstraints()
        setupUIDesignandFunction()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePresentationExpanded), name: .presentatonExpanded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePresentationShrinked), name: .presentationShrinked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSideBar), name: .menuButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSidebar), name: .shouldHideSideBar, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presentSearchBar()
        
        
    }
                                               
    deinit {
        NotificationCenter.default.removeObserver(self, name: .presentatonExpanded, object: nil)
        NotificationCenter.default.removeObserver(self, name: .presentationShrinked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .menuButtonTapped, object: nil)
        NotificationCenter.default.removeObserver(self, name: .shouldHideSideBar, object: nil)
    }
}



// MARK: - UI Config:
extension MainVC : UIViewControllerTransitioningDelegate{
    
    private func setupUIConstraints(){
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
                
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
        ])
    }
    
    private func setupUIDesignandFunction(){
        mapView.isUserInteractionEnabled = true

        // Hides the sidebar when the map is clicked.
        let mapTappedGesture = UITapGestureRecognizer(target: self, action: #selector(hideSidebar))
        mapView.addGestureRecognizer(mapTappedGesture)
    }
    
    private func presentSearchBar() {
        let searchVC = SearchVC()
        searchVC.modalPresentationStyle = .custom
        searchVC.transitioningDelegate = self // Assign transitioning delegate
        
        self.definesPresentationContext = true
        self.present(searchVC, animated: true)
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
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
   
  

}



