//
//  Bundle.swift
//  FastPark
//
//  Created by Mert Ziya on 15.02.2025.
//

import Foundation

extension Bundle {
    private static var bundleKey: UInt8 = 0

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    @objc static func localizedString(forKey key: String, value: String?, table: String?) -> String {
        let bundle = objc_getAssociatedObject(Bundle.main, &bundleKey) as? Bundle ?? Bundle.main
        return bundle.localizedString(forKey: key, value: value, table: table)
    }

    static func swizzleLocalization() {
        let original = class_getInstanceMethod(Bundle.self, #selector(Bundle.localizedString(forKey:value:table:)))
        let custom = class_getInstanceMethod(Bundle.self, #selector(Bundle.customLocalizedString(forKey:value:table:)))
        method_exchangeImplementations(original!, custom!)
    }

    @objc private func customLocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle = objc_getAssociatedObject(self, &Bundle.bundleKey) as? Bundle ?? self
        return bundle.customLocalizedString(forKey: key, value: value, table: tableName)
    }
}
