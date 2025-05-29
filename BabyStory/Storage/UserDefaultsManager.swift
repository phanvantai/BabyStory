import Foundation

// MARK: - Legacy Storage Manager (Deprecated)
// This class is deprecated. Use StorageManager.shared instead.
// Will be removed in a future version.

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let profileKey = "userProfile"
    private let storiesKey = "savedStories"
    private let themeKey = "selectedTheme"
    private let themeSettingsKey = "themeSettings"
    
    private let defaults = UserDefaults.standard
    
    func saveProfile(_ profile: UserProfile) throws {
        do {
            let data = try JSONEncoder().encode(profile)
            defaults.set(data, forKey: profileKey)
        } catch {
            throw AppError.profileSaveFailed
        }
    }
    
    func loadProfile() throws -> UserProfile? {
        guard let data = defaults.data(forKey: profileKey) else { return nil }
        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            throw AppError.dataCorruption
        }
    }
    
    func saveStories(_ stories: [Story]) throws {
        do {
            let data = try JSONEncoder().encode(stories)
            defaults.set(data, forKey: storiesKey)
        } catch {
            throw AppError.storySaveFailed
        }
    }
    
    func loadStories() throws -> [Story] {
        guard let data = defaults.data(forKey: storiesKey) else { return [] }
        do {
            return try JSONDecoder().decode([Story].self, from: data)
        } catch {
            throw AppError.dataCorruption
        }
    }
    
    // MARK: - Theme Management
    func saveTheme(_ theme: ThemeMode) {
        defaults.set(theme.rawValue, forKey: themeKey)
    }
    
    func loadTheme() -> ThemeMode {
        guard let savedTheme = defaults.string(forKey: themeKey),
              let theme = ThemeMode(rawValue: savedTheme) else {
            return .system
        }
        return theme
    }
}
