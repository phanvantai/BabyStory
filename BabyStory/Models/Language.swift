import Foundation

// MARK: - Language Model
struct Language: Codable, Hashable, CaseIterable {
  let code: String
  let name: String
  let nativeName: String
  let flag: String
  
  // MARK: - Static Language Definitions
  static let english = Language(code: "en", name: "English", nativeName: "English", flag: "🇺🇸")
//   static let spanish = Language(code: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸")
//   static let french = Language(code: "fr", name: "French", nativeName: "Français", flag: "🇫🇷")
//   static let german = Language(code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪")
//   static let italian = Language(code: "it", name: "Italian", nativeName: "Italiano", flag: "🇮🇹")
//   static let portuguese = Language(code: "pt", name: "Portuguese", nativeName: "Português", flag: "🇵🇹")
//   static let chinese = Language(code: "zh", name: "Chinese", nativeName: "中文", flag: "🇨🇳")
//   static let japanese = Language(code: "ja", name: "Japanese", nativeName: "日本語", flag: "🇯🇵")
//   static let korean = Language(code: "ko", name: "Korean", nativeName: "한국어", flag: "🇰🇷")
//   static let arabic = Language(code: "ar", name: "Arabic", nativeName: "العربية", flag: "🇸🇦")
  // vietnamese is intentionally excluded as per requirements
  static let vietnamese = Language(code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt", flag: "🇻🇳")
  
  // MARK: - CaseIterable Implementation
  static var allCases: [Language] = [
    .english,
    .vietnamese
//    .spanish,
//    .french,
//    .german,
//    .italian,
//    .portuguese,
//    .chinese,
//    .japanese,
//    .korean,
//    .arabic
  ]
  
  // MARK: - Helper Methods
  var displayName: String {
    return "\(flag) \(nativeName)"
  }
  
  var fullDisplayName: String {
    return "\(flag) \(nativeName) (\(name))"
  }
  
  /// Returns the default language based on the device's current locale
  static var deviceDefault: Language {
    let currentLocale = Locale.current.language.languageCode?.identifier ?? "en"
    return allCases.first { $0.code == currentLocale } ?? .english
  }
  
  /// Returns the user's preferred language from saved settings, or device default
  static var preferred: Language {
    if let savedLanguageCode = UserDefaults.standard.string(forKey: "selectedLanguage"),
       let savedLanguage = allCases.first(where: { $0.code == savedLanguageCode }) {
      return savedLanguage
    }
    return deviceDefault
  }
  
  /// Saves the language preference
  func save() {
    UserDefaults.standard.set(code, forKey: "selectedLanguage")
    
    UserDefaults.standard.synchronize()
    
    // Log the language change
    print("Language changed to: \(fullDisplayName)")
    
    // Update the app's language setting
    UserDefaults.standard.set([code], forKey: "AppleLanguages")
    UserDefaults.standard.synchronize()
  }
}

// MARK: - Language Extensions
extension Language: Identifiable {
  var id: String { code }
}

extension Language: Equatable {
  static func == (lhs: Language, rhs: Language) -> Bool {
    return lhs.code == rhs.code
  }
}
