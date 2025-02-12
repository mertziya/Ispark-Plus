//
//  HapticFeedBack.swift
//  FastPark
//
//  Created by Mert Ziya on 12.02.2025.
//

import Foundation
import UIKit

class HapticFeedbackManager {
    
    // Light impact feedback
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    // Medium impact feedback
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    // Heavy impact feedback
    static func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    // Success feedback (notification)
    static func successNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    // Warning feedback (notification)
    static func warningNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    // Error feedback (notification)
    static func errorNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // Selection feedback
    static func selectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
