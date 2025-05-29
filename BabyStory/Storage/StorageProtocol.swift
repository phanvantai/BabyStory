import Foundation

// MARK: - Storage Protocol
/// Abstract interface for data persistence operations
/// This allows switching between different storage implementations (UserDefaults, Core Data, CloudKit, etc.)
protocol StorageProtocol {
    // MARK: - Profile Management
    func saveProfile(_ profile: UserProfile) throws
    func loadProfile() throws -> UserProfile?
    
    // MARK: - Story Management
    func saveStories(_ stories: [Story]) throws
    func loadStories() throws -> [Story]
    
    // MARK: - Theme Management
    func saveTheme(_ theme: ThemeMode)
    func loadTheme() -> ThemeMode
    
    // MARK: - Settings Management
    func saveSetting<T: Codable>(_ value: T, forKey key: String) throws
    func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func removeSetting(forKey key: String)
    
    // MARK: - Batch Operations
    func clearAllData() throws
    func exportData() throws -> Data
    func importData(_ data: Data) throws
}

// MARK: - Storage Keys
/// Centralized storage keys to avoid magic strings
enum StorageKeys {
    static let userProfile = "userProfile"
    static let savedStories = "savedStories"
    static let selectedTheme = "selectedTheme"
    static let themeSettings = "themeSettings"
    static let narrationEnabled = "narrationEnabled"
    static let parentalLockEnabled = "parentalLockEnabled"
    static let parentalPasscode = "parentalPasscode"
}
