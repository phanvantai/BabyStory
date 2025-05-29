import Foundation

// MARK: - Storage Manager
/// Central storage manager that provides a single point of access to data persistence
/// This manager can switch between different storage implementations (UserDefaults, Core Data, CloudKit, etc.)
class StorageManager {
  
  // MARK: - Properties
  private let settingService: SettingsServiceProtocol
  private let storyService: StoryServiceProtocol
  private let themeService: ThemeServiceProtocol
  private let userProfileService: UserProfileServiceProtocol
  
  // MARK: - Singleton
  static let shared = StorageManager()
  
  // MARK: - Initialization
  private init() {
    self.settingService = ServiceFactory.shared.createSettingsService()
    self.storyService = ServiceFactory.shared.createStoryService()
    self.themeService = ServiceFactory.shared.createThemeService()
    self.userProfileService = ServiceFactory.shared.createUserProfileService()
  }
  
  // MARK: - Profile Management
  func saveProfile(_ profile: UserProfile) throws {
    try userProfileService.saveProfile(profile)
  }
  
  func loadProfile() throws -> UserProfile? {
    try userProfileService.loadProfile()
  }
  
  // MARK: - Story Management
  func saveStories(_ stories: [Story]) throws {
    try storyService.saveStories(stories)
  }
  
  func loadStories() throws -> [Story] {
    try storyService.loadStories()
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
    themeService.saveTheme(theme)
  }
  
  func loadTheme() -> ThemeMode {
    themeService.loadTheme()
  }
  
  // MARK: - Settings Management
  func saveNarrationEnabled(_ enabled: Bool) throws {
    try settingService.saveSetting(enabled, forKey: StorageKeys.narrationEnabled)
  }
  
  func loadNarrationEnabled() -> Bool {
    do {
      return try settingService.loadSetting(Bool.self, forKey: StorageKeys.narrationEnabled) ?? true
    } catch {
      return false // Default value
    }
  }
  
  func saveParentalLockEnabled(_ enabled: Bool) throws {
    try settingService.saveSetting(enabled, forKey: StorageKeys.parentalLockEnabled)
  }
  
  func loadParentalLockEnabled() -> Bool {
    do {
      return try settingService.loadSetting(Bool.self, forKey: StorageKeys.parentalLockEnabled) ?? false
    } catch {
      return false // Default value
    }
  }
  
  func saveParentalPasscode(_ passcode: String) throws {
    try settingService.saveSetting(passcode, forKey: StorageKeys.parentalPasscode)
  }
  
  func loadParentalPasscode() -> String? {
    do {
      return try settingService.loadSetting(String.self, forKey: StorageKeys.parentalPasscode)
    } catch {
      return nil
    }
  }
  
  // Generic setting management
  func saveSetting<T: Codable>(_ value: T, forKey key: String) throws {
    try settingService.saveSetting(value, forKey: key)
  }
  
  func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
    try settingService.loadSetting(type, forKey: key)
  }
  
  func removeSetting(forKey key: String) {
    settingService.removeSetting(forKey: key)
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
