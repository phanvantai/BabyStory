import Foundation

// MARK: - UserDefaults Storage Implementation
/// Concrete implementation of StorageProtocol using UserDefaults
/// This maintains backward compatibility with existing UserDefaultsManager
class UserDefaultsStorage: StorageProtocol {
    
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Singleton
    static let shared = UserDefaultsStorage()
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // MARK: - Profile Management
    func saveProfile(_ profile: UserProfile) throws {
        do {
            let data = try encoder.encode(profile)
            defaults.set(data, forKey: StorageKeys.userProfile)
        } catch {
            throw AppError.profileSaveFailed
        }
    }
    
    func loadProfile() throws -> UserProfile? {
        guard let data = defaults.data(forKey: StorageKeys.userProfile) else { 
            return nil 
        }
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            throw AppError.dataCorruption
        }
    }
    
    // MARK: - Story Management
    func saveStories(_ stories: [Story]) throws {
        do {
            let data = try encoder.encode(stories)
            defaults.set(data, forKey: StorageKeys.savedStories)
        } catch {
            throw AppError.storySaveFailed
        }
    }
    
    func loadStories() throws -> [Story] {
        guard let data = defaults.data(forKey: StorageKeys.savedStories) else { 
            return [] 
        }
        do {
            return try decoder.decode([Story].self, from: data)
        } catch {
            throw AppError.dataCorruption
        }
    }
    
    // MARK: - Theme Management
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
    
    // MARK: - Settings Management
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
    
    // MARK: - Batch Operations
    func clearAllData() throws {
        let keysToRemove = [
            StorageKeys.userProfile,
            StorageKeys.savedStories,
            StorageKeys.selectedTheme,
            StorageKeys.themeSettings,
            StorageKeys.narrationEnabled,
            StorageKeys.parentalLockEnabled,
            StorageKeys.parentalPasscode
        ]
        
        for key in keysToRemove {
            defaults.removeObject(forKey: key)
        }
    }
    
    func exportData() throws -> Data {
        let exportData = ExportData(
            profile: try loadProfile(),
            stories: try loadStories(),
            theme: loadTheme(),
            settings: extractSettings()
        )
        
        do {
            return try encoder.encode(exportData)
        } catch {
            throw AppError.dataExportFailed
        }
    }
    
    func importData(_ data: Data) throws {
        do {
            let importData = try decoder.decode(ExportData.self, from: data)
            
            // Import profile
            if let profile = importData.profile {
                try saveProfile(profile)
            }
            
            // Import stories
            try saveStories(importData.stories)
            
            // Import theme
            saveTheme(importData.theme)
            
            // Import settings
            for (key, value) in importData.settings {
                defaults.set(value, forKey: key)
            }
            
        } catch {
            throw AppError.dataImportFailed
        }
    }
    
    // MARK: - Private Helpers
    private func extractSettings() -> [String: Any] {
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

/// Data structure for export/import operations
private struct ExportData: Codable {
    let profile: UserProfile?
    let stories: [Story]
    let theme: ThemeMode
    let settings: [String: AnyCodable]
    
    init(profile: UserProfile?, stories: [Story], theme: ThemeMode, settings: [String: Any]) {
        self.profile = profile
        self.stories = stories
        self.theme = theme
        self.settings = settings.mapValues { AnyCodable($0) }
    }
}

/// Helper for encoding/decoding Any values
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
