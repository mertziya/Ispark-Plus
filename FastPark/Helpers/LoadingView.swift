//
//  LoadingView.swift
//  FastPark
//
//  Created by Mert Ziya on 11.02.2025.
//

import Foundation
import UIKit

class LoadingView {
    static func showLoading(on vc: UIViewController , loadingMessage: String) {
        DispatchQueue.main.async {
            let loadingView = UIView(frame: vc.view.bounds)
            loadingView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
            loadingView.tag = 999 // Unique tag to identify the loading view
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.startAnimating()
            
            let loadingLabel = UILabel()
            loadingLabel.text = loadingMessage
            loadingLabel.textColor = .label.withAlphaComponent(0.7)
            loadingLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
            loadingLabel.textAlignment = .center
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            
            loadingView.addSubview(loadingLabel)
            loadingView.addSubview(activityIndicator)
            vc.view.addSubview(loadingView)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
                
                loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(equalTo: activityIndicator.topAnchor, constant: -10) // Adjust spacing as needed
            ])
        }
    }
    
    static func hideLoading(from vc: UIViewController) {
        
        DispatchQueue.main.async {
            if let loadingView = vc.view.viewWithTag(999) {
                loadingView.removeFromSuperview()
            }
        }
    }
}
