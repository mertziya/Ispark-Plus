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
    
    static func openMapsAlert(at viewController : UIViewController, lat : String , lng : String){
        let appleMapsURL = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lng)")!
        let googleMapsAppURL = URL(string: "comgooglemaps://?daddr=\(lat),\(lng)&directionsmode=driving")!
        let googleMapsWebURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat),\(lng)")!

        let alertController = UIAlertController(title: NSLocalizedString("Open in Maps", comment: "")
                                                , message: NSLocalizedString("Choose an app to open directions", comment: ""), preferredStyle: .actionSheet)

        // Apple Maps option
        alertController.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            UIApplication.shared.open(appleMapsURL)
        }))

        // Google Maps option (only if installed)
        alertController.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            UIApplication.shared.open(googleMapsWebURL)
        }))
    

        // Cancel action
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        // Present the action sheet
        viewController.present(alertController, animated: true, completion: nil)

        print("handle directions clicked here!")
    }
    
}


