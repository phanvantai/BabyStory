import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let profileKey = "userProfile"
    private let storiesKey = "savedStories"
    private let themeKey = "selectedTheme"
    private let themeSettingsKey = "themeSettings"
    
    private let defaults = UserDefaults.standard
    
    func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: profileKey)
        }
    }
    
    func loadProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    func saveStories(_ stories: [Story]) {
        if let data = try? JSONEncoder().encode(stories) {
            defaults.set(data, forKey: storiesKey)
        }
    }
    
    func loadStories() -> [Story] {
        guard let data = defaults.data(forKey: storiesKey) else { return [] }
        return (try? JSONDecoder().decode([Story].self, from: data)) ?? []
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
