//
//  PresentationVC.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import Foundation

import UIKit


class SearchVCPresentation: UIPresentationController {
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var initialHeight: CGFloat = 110 // Initial height
    private let expandedHeight: CGFloat = Constants.deviceHeight - 60 // Expanded height
    private let threshold: CGFloat = 120 // Threshold for snapping
    
    private var currentHeight : CGFloat?

    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        containerView.frame = CGRect(
                        x: 0,
                        y: Constants.deviceHeight - initialHeight,
                        width: Constants.deviceWidth,
                        height: self.initialHeight
                    )
        let height = initialHeight
        currentHeight = height
        
        NotificationCenter.default.addObserver(self, selector: #selector(expandVC), name: .searchBarClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideView), name: .menuButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unhideView), name: .sideBarClosed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shrinkVC), name: .districtSelected, object: nil)

        return CGRect(x: 0,
                      y: containerView.bounds.height - currentHeight!,
                      width: containerView.bounds.width,
                      height: currentHeight!)
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: .searchBarClicked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .menuButtonTapped, object: nil)
        NotificationCenter.default.removeObserver(self, name: .sideBarClosed, object: nil)
        NotificationCenter.default.removeObserver(self, name: .districtSelected, object: nil)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let presentedView = presentedView else { return }
        
        // Add pan gesture for dragging
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        presentedView.addGestureRecognizer(panGestureRecognizer)
        
        presentedView.layer.cornerRadius = 15
        presentedView.clipsToBounds = true
    }
  
    
    

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let containerView = containerView, let _ = presentedView else { return }
        
        let translation = gesture.translation(in: containerView)
        var newHeight : CGFloat = 100
        switch gesture.state {
        case .changed:
            let pixelsSwiped = (translation.y > 0) ? translation.y : 0
            if currentHeight == initialHeight{
                newHeight = initialHeight - translation.y
                updatePresentedViewHeight(newHeight)
            }else if currentHeight == expandedHeight{
                let newHeight = expandedHeight - pixelsSwiped
                updatePresentedViewHeight(newHeight)
            }
            
            
        case .ended:
            if abs(translation.y) > threshold{
                if currentHeight == initialHeight{
                    animateHeightChange(to: expandedHeight)
                    currentHeight = expandedHeight
                    NotificationCenter.default.post(name: .presentatonExpanded, object: nil)
                }else if currentHeight == expandedHeight && translation.y > 0{
                    animateHeightChange(to: initialHeight)
                    currentHeight = initialHeight
                    NotificationCenter.default.post(name: .presentationShrinked, object: nil)
                }
            } else {
                if currentHeight == initialHeight{
                    animateHeightChange(to: initialHeight)
                }else if currentHeight == expandedHeight{
                    animateHeightChange(to: expandedHeight)
                }
            }
            
        default:
            break
        }
    }

    private func updatePresentedViewHeight(_ height: CGFloat) {
        guard let presentedView = presentedView, let containerView = containerView else { return }
        let newFrame = CGRect(x: 0,
                              y: containerView.bounds.height - height,
                              width: containerView.bounds.width,
                              height: height)
        presentedView.frame = newFrame
    }
    
    private func animateHeightChange(to height: CGFloat) {
        containerView?.setNeedsLayout()
        self.currentHeight = height
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.containerView?.frame = CGRect(
                            x: 0,
                            y: Constants.deviceHeight - self.currentHeight!,
                            width: Constants.deviceWidth,
                            height: self.currentHeight!
                        )
            self.updatePresentedViewHeight(height)
        })
        
    }
    
    @objc private func expandVC(){
        animateHeightChange(to: expandedHeight)
        currentHeight = expandedHeight
        NotificationCenter.default.post(name: .presentatonExpanded, object: nil)
    }
    
    @objc private func shrinkVC(){
        animateHeightChange(to: initialHeight)
        currentHeight = initialHeight
        NotificationCenter.default.post(name: .presentationShrinked, object: nil)
    }
    
    @objc private func hideView(){
        animateHeightChange(to: 0)
    }
    @objc private func unhideView(){
        animateHeightChange(to: self.initialHeight)
    }
}
