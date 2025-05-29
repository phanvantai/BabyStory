import Foundation

// MARK: - Storage Manager
/// Central storage manager that provides a single point of access to data persistence
/// This manager can switch between different storage implementations (UserDefaults, Core Data, CloudKit, etc.)
class StorageManager {
    
    // MARK: - Properties
    private let storage: StorageProtocol
    
    // MARK: - Singleton
    static let shared = StorageManager()
    
    // MARK: - Initialization
    private init(storage: StorageProtocol = UserDefaultsStorage.shared) {
        self.storage = storage
    }
    
    // For testing or switching storage implementations
    init(customStorage: StorageProtocol) {
        self.storage = customStorage
    }
    
    // MARK: - Profile Management
    func saveProfile(_ profile: UserProfile) throws {
        try storage.saveProfile(profile)
    }
    
    func loadProfile() throws -> UserProfile? {
        try storage.loadProfile()
    }
    
    // MARK: - Story Management
    func saveStories(_ stories: [Story]) throws {
        try storage.saveStories(stories)
    }
    
    func loadStories() throws -> [Story] {
        try storage.loadStories()
    }
    
    func saveStory(_ story: Story) throws {
        var stories = try loadStories()
        
        // Check if story already exists and update it, otherwise append
        if let existingIndex = stories.firstIndex(where: { $0.id == story.id }) {
            stories[existingIndex] = story
        } else {
            stories.append(story)
        }
        
        try saveStories(stories)
    }
    
    func deleteStory(withId id: UUID) throws {
        var stories = try loadStories()
        stories.removeAll { $0.id == id }
        try saveStories(stories)
    }
    
    func toggleStoryFavorite(withId id: UUID) throws {
        var stories = try loadStories()
        
        if let index = stories.firstIndex(where: { $0.id == id }) {
            stories[index].isFavorite.toggle()
            try saveStories(stories)
        }
    }
    
    // MARK: - Theme Management
    func saveTheme(_ theme: ThemeMode) {
        storage.saveTheme(theme)
    }
    
    func loadTheme() -> ThemeMode {
        storage.loadTheme()
    }
    
    // MARK: - Settings Management
    func saveNarrationEnabled(_ enabled: Bool) throws {
        try storage.saveSetting(enabled, forKey: StorageKeys.narrationEnabled)
    }
    
    func loadNarrationEnabled() -> Bool {
        do {
            return try storage.loadSetting(Bool.self, forKey: StorageKeys.narrationEnabled) ?? true
        } catch {
            return true // Default value
        }
    }
    
    func saveParentalLockEnabled(_ enabled: Bool) throws {
        try storage.saveSetting(enabled, forKey: StorageKeys.parentalLockEnabled)
    }
    
    func loadParentalLockEnabled() -> Bool {
        do {
            return try storage.loadSetting(Bool.self, forKey: StorageKeys.parentalLockEnabled) ?? false
        } catch {
            return false // Default value
        }
    }
    
    func saveParentalPasscode(_ passcode: String) throws {
        try storage.saveSetting(passcode, forKey: StorageKeys.parentalPasscode)
    }
    
    func loadParentalPasscode() -> String? {
        do {
            return try storage.loadSetting(String.self, forKey: StorageKeys.parentalPasscode)
        } catch {
            return nil
        }
    }
    
    // Generic setting management
    func saveSetting<T: Codable>(_ value: T, forKey key: String) throws {
        try storage.saveSetting(value, forKey: key)
    }
    
    func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        try storage.loadSetting(type, forKey: key)
    }
    
    func removeSetting(forKey key: String) {
        storage.removeSetting(forKey: key)
    }
    
    // MARK: - Batch Operations
    func clearAllData() throws {
        try storage.clearAllData()
    }
    
    func exportData() throws -> Data {
        try storage.exportData()
    }
    
    func importData(_ data: Data) throws {
        try storage.importData(data)
    }
    
    // MARK: - Data Migration
    /// Migrate data from old UserDefaultsManager to new storage system
    func migrateFromLegacyStorage() throws {
        // This method can be used to migrate data if needed
        // For now, since we're using the same UserDefaults keys, no migration is needed
        print("Storage migration completed successfully")
    }
    
    // MARK: - Validation
    func validateDataIntegrity() throws -> Bool {
        // Validate that stored data is not corrupted
        do {
            let _ = try loadProfile()
            let _ = try loadStories()
            let _ = loadTheme()
            return true
        } catch {
            throw AppError.dataCorruption
        }
    }
}

// MARK: - Storage Manager Extensions
extension StorageManager {
    
    // MARK: - Convenience Methods
    
    /// Check if user has completed onboarding
    var hasCompletedOnboarding: Bool {
        do {
            return try loadProfile() != nil
        } catch {
            return false
        }
    }
    
    /// Get total number of saved stories
    var totalStoriesCount: Int {
        do {
            return try loadStories().count
        } catch {
            return 0
        }
    }
    
    /// Get favorite stories count
    var favoriteStoriesCount: Int {
        do {
            return try loadStories().filter { $0.isFavorite }.count
        } catch {
            return 0
        }
    }
    
    /// Get stories created today
    func getStoriesCreatedToday() throws -> [Story] {
        let stories = try loadStories()
        let today = Calendar.current.startOfDay(for: Date())
        
        return stories.filter { story in
          Calendar.current.isDate(story.date, inSameDayAs: today)
        }
    }
    
    /// Get recent stories (last 7 days)
    func getRecentStories(days: Int = 7) throws -> [Story] {
        let stories = try loadStories()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return stories.filter { story in
            story.date >= cutoffDate
        }.sorted { $0.date > $1.date }
    }
}
