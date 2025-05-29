import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let profileKey = "userProfile"
    private let storiesKey = "savedStories"
    
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
}
