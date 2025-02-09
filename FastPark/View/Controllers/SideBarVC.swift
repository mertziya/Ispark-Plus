//
//  SideBarVC.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import UIKit

class SideBarVC: UIViewController {

    @IBOutlet weak var sideBarContentView: UIView!
    @IBOutlet weak var swipeIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}


// MARK: - UI Configurations:
extension SideBarVC{
    private func setupUI(){
        view.backgroundColor = .clear
        sideBarContentView.layer.cornerRadius = 24
        swipeIndicatorView.layer.cornerRadius = 4 / 2
        
        sideBarContentView.isUserInteractionEnabled = true
        let sidebarSwipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedToRight))
        sidebarSwipeRightGesture.direction = .right
        sideBarContentView.addGestureRecognizer(sidebarSwipeRightGesture)
    }
}


// MARK: - Actions:
extension SideBarVC{
    
    @objc private func swipedToRight(){
        NotificationCenter.default.post(name: .shouldHideSideBar, object: nil)
    }
}
