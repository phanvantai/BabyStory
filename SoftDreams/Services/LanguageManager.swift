//
//  LanguageManager.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 31/5/25.
//

import Foundation
import ObjectiveC

class LanguageManager: ObservableObject {
  
  static let shared = LanguageManager()
  @Published var currentLanguage: String {
    didSet {
      // Only update the Bundle, don't save to UserDefaults here
      // UserDefaults saving is handled by Language.save()
      Bundle.setLanguage(currentLanguage)
    }
  }
  
  private init() {
    currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Locale.current.language.languageCode?.identifier ?? "en"
    Bundle.setLanguage(currentLanguage)
  }
  
  /// Updates the current language and saves to UserDefaults
  func updateLanguage(_ languageCode: String) {
    UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
    UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
    UserDefaults.standard.synchronize()
    
    // This will trigger the didSet which updates the Bundle
    currentLanguage = languageCode
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

private class BundleEx: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let associated = objc_getAssociatedObject(self, &bundleKey) as? Bundle
        return associated?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}
