import Foundation

class HomeViewModel: ObservableObject {
  @Published var profile: UserProfile?
  @Published var stories: [Story] = []
  @Published var error: AppError?
  
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
      
      // Check if profile needs updating
      if let profile = profile, profile.needsUpdate {
        Logger.warning("User profile needs updating (last updated: \(profile.lastUpdate))", category: .userProfile)
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
}
