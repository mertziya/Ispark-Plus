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
        let sidebarSwipeRightGesture = UIPanGestureRecognizer(target: self, action: #selector(dragView(_:)))
        sideBarContentView.addGestureRecognizer(sidebarSwipeRightGesture)
    }
}


// MARK: - Actions:
extension SideBarVC{
    
    // Handle closing the sidebar smoothly
    @objc private func dragView(_ gesture : UIPanGestureRecognizer){
        let translation = gesture.translation(in: sideBarContentView)
        let isSwipedRightReallyFast = gesture.velocity(in: sideBarContentView).x > 1000
        var newX: CGFloat = 0
        
        switch gesture.state{
        case .changed,.began:
            newX = translation.x + 24 // 24 is the distance of sidebarcontentview from view initially
            if newX < 24 {newX = 24}
            sideBarContentView.frame = CGRect(x: newX,
                                              y: sideBarContentView.frame.minY,
                                              width: sideBarContentView.bounds.width,
                                              height: sideBarContentView.bounds.height)
        case .ended:
            if sideBarContentView.frame.minX > 80 || isSwipedRightReallyFast{
                view.frame = CGRect(x: sideBarContentView.frame.minX + 40,
                                    y: view.frame.minY,
                                    width: view.bounds.width,
                                    height: view.bounds.height)
                NotificationCenter.default.post(name: .shouldHideSideBar, object: nil)
            }else{
                UIView.animate(withDuration: 0.2) { [self] in
                    self.sideBarContentView.frame = CGRect(x: 24,
                                                      y: sideBarContentView.frame.minY,
                                                      width: sideBarContentView.bounds.width,
                                                      height: sideBarContentView.bounds.height)
                }
            }
        default:
            break
        }
    }
    
}
