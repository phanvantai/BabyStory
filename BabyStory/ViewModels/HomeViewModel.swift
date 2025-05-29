import Foundation

class HomeViewModel: ObservableObject {
  @Published var profile: UserProfile?
  @Published var stories: [Story] = []
  @Published var error: AppError?
  
  init() {
    refresh()
  }
  
  func refresh() {
    do {
      profile = try StorageManager.shared.loadProfile()
      stories = try StorageManager.shared.loadStories()
      error = nil
    } catch {
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
