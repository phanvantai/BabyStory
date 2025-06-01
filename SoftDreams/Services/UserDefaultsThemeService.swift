import Foundation

// MARK: - UserDefaults Theme Service
/// UserDefaults implementation of ThemeServiceProtocol
class UserDefaultsThemeService: ThemeServiceProtocol {
  
  // MARK: - Properties
  private let defaults = UserDefaults.standard
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  
  // MARK: - ThemeServiceProtocol Implementation
  
  func saveTheme(_ theme: ThemeMode) {
    defaults.set(theme.rawValue, forKey: StorageKeys.selectedTheme)
  }
  
  func loadTheme() -> ThemeMode {
    guard let savedTheme = defaults.string(forKey: StorageKeys.selectedTheme),
          let theme = ThemeMode(rawValue: savedTheme) else {
      return .system
    }
    return theme
  }
  
  func resetTheme() {
    defaults.removeObject(forKey: StorageKeys.selectedTheme)
    defaults.removeObject(forKey: StorageKeys.themeSettings)
  }
  
  func hasCustomTheme() -> Bool {
    return defaults.string(forKey: StorageKeys.selectedTheme) != nil
  }
  
  func saveThemeSettings(_ settings: [String: Any], for theme: ThemeMode) {
    let key = "\(StorageKeys.themeSettings)_\(theme.rawValue)"
    let codableSettings = settings.mapValues { AnyCodable($0) }
    do {
      let data = try encoder.encode(codableSettings)
      defaults.set(data, forKey: key)
    } catch {
      print("Failed to save theme settings: \(error)")
    }
  }
  
  func loadThemeSettings(for theme: ThemeMode) -> [String: Any] {
    let key = "\(StorageKeys.themeSettings)_\(theme.rawValue)"
    guard let data = defaults.data(forKey: key) else {
      return [:]
    }
    
    do {
      let codableSettings = try decoder.decode([String: AnyCodable].self, from: data)
      return codableSettings.mapValues { $0.value }
    } catch {
      print("Failed to load theme settings: \(error)")
      return [:]
    }
  }
}

// MARK: - Supporting Types
/// Helper for encoding/decoding Any values in theme settings
private struct AnyCodable: Codable {
  let value: Any
  
  init(_ value: Any) {
    self.value = value
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    
    if let bool = try? container.decode(Bool.self) {
      value = bool
    } else if let int = try? container.decode(Int.self) {
      value = int
    } else if let double = try? container.decode(Double.self) {
      value = double
    } else if let string = try? container.decode(String.self) {
      value = string
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    
    if let bool = value as? Bool {
      try container.encode(bool)
    } else if let int = value as? Int {
      try container.encode(int)
    } else if let double = value as? Double {
      try container.encode(double)
    } else if let string = value as? String {
      try container.encode(string)
    } else {
      throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unsupported type"))
    }
  }
}
