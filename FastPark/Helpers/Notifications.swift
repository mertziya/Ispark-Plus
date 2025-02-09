//
//  Notifications.swift
//  FastPark
//
//  Created by Mert Ziya on 9.02.2025.
//

import Foundation

extension Notification.Name{
    static let searchBarClicked = Notification.Name("searchbarClicked")
    static let presentationShrinked = Notification.Name("presentationShrinked")
    static let presentatonExpanded = Notification.Name("PresentationExpanded")
    static let menuButtonTapped = Notification.Name("MenuButtonTapped")
    static let sideBarClosed = Notification.Name("SideBarClosed")
    static let shouldHideSideBar = Notification.Name("shouldHideSideBar")
}
