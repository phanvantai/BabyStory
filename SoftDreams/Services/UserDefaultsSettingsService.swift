import Foundation

enum StorageKeys {
  static let userProfile = "userProfile"
  static let savedStories = "savedStories"
  static let selectedTheme = "selectedTheme"
  static let themeSettings = "themeSettings"
  static let narrationEnabled = "narrationEnabled"
  static let parentalLockEnabled = "parentalLockEnabled"
  static let parentalPasscode = "parentalPasscode"
  static let openAIAPIKey = "openAIAPIKey"
}

// MARK: - UserDefaults Settings Service
/// UserDefaults implementation of SettingsServiceProtocol
class UserDefaultsSettingsService: SettingsServiceProtocol {
  
  // MARK: - Properties
  private let defaults = UserDefaults.standard
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  
  // MARK: - SettingsServiceProtocol Implementation
  
  func saveSetting<T: Codable>(_ value: T, forKey key: String) throws {
    if let simpleValue = value as? PropertyListValue {
      // For simple types (String, Int, Bool, etc.), save directly
      defaults.set(simpleValue, forKey: key)
    } else {
      // For complex types, encode as JSON
      do {
        let data = try encoder.encode(value)
        defaults.set(data, forKey: key)
      } catch {
        throw AppError.dataSaveFailed
      }
    }
  }
  
  func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
    if type == String.self {
      return defaults.string(forKey: key) as? T
    } else if type == Int.self {
      return defaults.integer(forKey: key) as? T
    } else if type == Bool.self {
      return defaults.bool(forKey: key) as? T
    } else if type == Double.self {
      return defaults.double(forKey: key) as? T
    } else if type == Float.self {
      return defaults.float(forKey: key) as? T
    } else {
      // For complex types, decode from JSON
      guard let data = defaults.data(forKey: key) else {
        return nil
      }
      do {
        return try decoder.decode(type, from: data)
      } catch {
        throw AppError.dataCorruption
      }
    }
  }
  
  func removeSetting(forKey key: String) {
    defaults.removeObject(forKey: key)
  }
  
  func getAllSettings() throws -> [String: Any] {
    return extractAllSettings()
  }
  
  func settingExists(forKey key: String) -> Bool {
    return defaults.object(forKey: key) != nil
  }
  
  func getAllSettingKeys() -> [String] {
    return Array(defaults.dictionaryRepresentation().keys)
  }
  
  func saveSettings(_ settings: [String: Any]) throws {
    for (key, value) in settings {
      defaults.set(value, forKey: key)
    }
  }
  
  func removeSettings(forKeys keys: [String]) {
    for key in keys {
      defaults.removeObject(forKey: key)
    }
  }
  
  func resetAllSettings() throws {
    let settingsKeys = [
      StorageKeys.narrationEnabled,
      StorageKeys.parentalLockEnabled,
      StorageKeys.parentalPasscode
    ]
    removeSettings(forKeys: settingsKeys)
  }
  
  // MARK: - Private Helpers
  
  private func extractAllSettings() -> [String: Any] {
    var settings: [String: Any] = [:]
    
    if defaults.object(forKey: StorageKeys.narrationEnabled) != nil {
      settings[StorageKeys.narrationEnabled] = defaults.bool(forKey: StorageKeys.narrationEnabled)
    }
    
    if defaults.object(forKey: StorageKeys.parentalLockEnabled) != nil {
      settings[StorageKeys.parentalLockEnabled] = defaults.bool(forKey: StorageKeys.parentalLockEnabled)
    }
    
    if let passcode = defaults.string(forKey: StorageKeys.parentalPasscode) {
      settings[StorageKeys.parentalPasscode] = passcode
    }
    
    return settings
  }
}

// MARK: - Supporting Types
/// Protocol for types that can be stored directly in UserDefaults
private protocol PropertyListValue {}
extension String: PropertyListValue {}
extension Int: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
extension Data: PropertyListValue {}
extension Date: PropertyListValue {}
