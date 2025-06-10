//
//  Localization.swift
//  DevOS
//
//  Created by Juan Daniel Vázquez Alonso on 28/05/25.
//

import Foundation
import ObjectiveC

extension Bundle {
    private static var bundleKey: UInt8 = 0

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let newBundle = Bundle(path: path) else { return }

        objc_setAssociatedObject(Bundle.main, &bundleKey, newBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    static var localized: Bundle {
        objc_getAssociatedObject(Bundle.main, &bundleKey) as? Bundle ?? Bundle.main
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: Bundle.localized, comment: "")
    }
}
