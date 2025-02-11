//
//  Alerts.swift
//  FastPark
//
//  Created by Mert Ziya on 11.02.2025.
//

import Foundation
import UIKit

class Alerts{
    
    static func showErrorAlert(on vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "TAMAM", style: .default)
        alert.addAction(action)
        
        // Check if there's already a presented view controller
        if let presentedVC = vc.presentedViewController {
            presentedVC.present(alert, animated: true)
        } else {
            vc.present(alert, animated: true)
        }
    }
    
}


