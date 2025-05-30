import Foundation

class HomeViewModel: ObservableObject {
  @Published var profile: UserProfile?
  @Published var stories: [Story] = []
  @Published var error: AppError?
  
  // Auto-update properties
  @Published var autoUpdateNotificationManager = AutoUpdateNotificationManager()
  private let autoUpdateService = AutoProfileUpdateService()
  
  init() {
    refresh()
  }
  
  func refresh() {
    Logger.info("Refreshing home view data", category: .userProfile)
    do {
      profile = try StorageManager.shared.loadProfile()
      stories = try StorageManager.shared.loadStories()
      error = nil
      
      // Log current app state
      Logger.info("Home refresh completed - Stories count: \(stories.count)", category: .userProfile)
      
      // Check for auto-updates
      Task {
        await checkAndPerformAutoUpdates()
      }
      
    } catch {
      Logger.error("Failed to refresh home data: \(error.localizedDescription)", category: .userProfile)
      self.error = error as? AppError ?? .dataCorruption
    }
  }
  
  func saveStory(_ story: Story) {
    do {
      stories.append(story)
      try StorageManager.shared.saveStories(stories)
      error = nil
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  // MARK: - Story Generation Methods
  @MainActor
  func generateTodaysStory(
    using storyGenVM: StoryGenerationViewModel,
    completion: @escaping (Story?) -> Void
  ) {
    Task {
      do {
        self.error = nil
        if let profile = self.profile {
          await storyGenVM.generateStory(profile: profile, options: nil)
          if let storyError = storyGenVM.error {
            self.error = storyError
            completion(nil)
          } else {
            completion(storyGenVM.generatedStory)
          }
        } else {
          self.error = .invalidProfile
          completion(nil)
        }
      }
    }
  }
  
  @MainActor
  func generateCustomStory(
    using storyGenVM: StoryGenerationViewModel,
    completion: @escaping (Story?) -> Void
  ) {
    Task {
      do {
        self.error = nil
        if let profile = self.profile {
          await storyGenVM.generateStory(profile: profile, options: storyGenVM.options)
          if let storyError = storyGenVM.error {
            self.error = storyError
            completion(nil)
          } else {
            completion(storyGenVM.generatedStory)
          }
        } else {
          self.error = .invalidProfile
          completion(nil)
        }
      }
    }
  }
  
  /// Log current profile information for debugging
  func logCurrentProfileInfo() {
    StorageManager.shared.logCurrentAppState()
  }
  
  // MARK: - Enhanced Storage Methods
  func saveStoryToLibrary(_ story: Story) {
    do {
      try StorageManager.shared.saveStory(story)
      refresh() // Refresh to get updated stories list
      error = nil
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  // MARK: - Convenience Properties
  var hasCompletedOnboarding: Bool {
    return StorageManager.shared.hasCompletedOnboarding
  }
  
  var totalStoriesCount: Int {
    return StorageManager.shared.totalStoriesCount
  }
  
  func getStoriesCreatedToday() -> [Story] {
    do {
      return try StorageManager.shared.getStoriesCreatedToday()
    } catch {
      self.error = error as? AppError ?? .dataCorruption
      return []
    }
  }
  
  // MARK: - Auto-Update Methods
  
  /// Checks and performs automatic profile updates
  @MainActor
  private func checkAndPerformAutoUpdates() async {
    guard autoUpdateService.needsAutoUpdate() else {
      Logger.debug("No auto-updates needed", category: .autoUpdate)
      return
    }
    
    Logger.info("Performing automatic profile updates", category: .autoUpdate)
    let result = await autoUpdateService.performAutoUpdate()
    
    if result.isSuccess && result.hasUpdates {
      // Refresh profile with updates
      do {
        profile = try StorageManager.shared.loadProfile()
        
        // Process notifications
        autoUpdateNotificationManager.processUpdateResult(result)
        
        Logger.info("Auto-update completed successfully", category: .autoUpdate)
      } catch {
        Logger.error("Failed to reload profile after auto-update: \(error.localizedDescription)", category: .autoUpdate)
        self.error = error as? AppError ?? .dataCorruption
      }
    } else if let error = result.error {
      Logger.error("Auto-update failed: \(error.localizedDescription)", category: .autoUpdate)
      // Don't show error to user for auto-updates, just log it
    }
  }
  
  /// Manually triggers auto-update check (for testing or manual refresh)
  func triggerAutoUpdate() {
    Task {
      await checkAndPerformAutoUpdates()
    }
  }
}
