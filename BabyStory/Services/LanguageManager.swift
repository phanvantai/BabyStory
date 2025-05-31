//
//  LanguageManager.swift
//  BabyStory
//
//  Created by Tai Phan Van on 31/5/25.
//

import Foundation

class LanguageManager: ObservableObject {
  
  static let shared = LanguageManager()
  @Published var currentLanguage: String {
          didSet {
              UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
              Bundle.setLanguage(currentLanguage)
          }
      }
  private init() {
          currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Locale.current.languageCode ?? "en"
          Bundle.setLanguage(currentLanguage)
      }
}

private var bundleKey: UInt8 = 0

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, BundleEx.self)
        }

        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")!), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let associated = objc_getAssociatedObject(self, &bundleKey) as? Bundle
        return associated?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}
