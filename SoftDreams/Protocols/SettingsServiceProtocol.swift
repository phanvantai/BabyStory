import Foundation

// MARK: - Settings Service Protocol
/// Handles generic application settings persistence
protocol SettingsServiceProtocol {
  /// Save a codable value for a specific key
  /// - Parameters:
  ///   - value: The value to save
  ///   - key: The key to associate with the value
  /// - Throws: Storage error if save operation fails
  func saveSetting<T: Codable>(_ value: T, forKey key: String) throws
  
  /// Load a codable value for a specific key
  /// - Parameters:
  ///   - type: The type of value to load
  ///   - key: The key to load the value for
  /// - Returns: The loaded value if it exists, nil otherwise
  /// - Throws: Storage error if load operation fails
  func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
  
  /// Remove a setting for a specific key
  /// - Parameter key: The key to remove
  func removeSetting(forKey key: String)
  
  /// Get all settings as a dictionary
  /// - Returns: Dictionary containing all settings
  /// - Throws: Storage error if load operation fails
  func getAllSettings() throws -> [String: Any]
  
  /// Check if a setting exists for a specific key
  /// - Parameter key: The key to check
  /// - Returns: true if setting exists, false otherwise
  func settingExists(forKey key: String) -> Bool
  
  /// Get all setting keys
  /// - Returns: Array of all setting keys
  func getAllSettingKeys() -> [String]
  
  /// Save multiple settings at once
  /// - Parameter settings: Dictionary of settings to save
  /// - Throws: Storage error if save operation fails
  func saveSettings(_ settings: [String: Any]) throws
  
  /// Remove multiple settings at once
  /// - Parameter keys: Array of keys to remove
  func removeSettings(forKeys keys: [String])
  
  /// Reset all settings to defaults
  /// - Throws: Storage error if reset operation fails
  func resetAllSettings() throws
}
