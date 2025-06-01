import Foundation

class LibraryViewModel: ObservableObject {
  @Published var stories: [Story] = []
  @Published var error: AppError?
  
  init() {
    loadStories()
  }
  
  func loadStories() {
    do {
      stories = try StorageManager.shared.loadStories()
      error = nil
    } catch {
      self.error = error as? AppError ?? .dataCorruption
    }
  }
  
  func toggleFavorite(for story: Story) {
    do {
      if let index = stories.firstIndex(where: { $0.id == story.id }) {
        stories[index].isFavorite.toggle()
        try StorageManager.shared.saveStories(stories)
        error = nil
      }
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  // MARK: - Enhanced Storage Methods
  func deleteStory(_ story: Story) {
    do {
      try StorageManager.shared.deleteStory(withId: story.id)
      loadStories() // Refresh the list
      error = nil
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  func saveStory(_ story: Story) {
    do {
      try StorageManager.shared.saveStory(story)
      loadStories() // Refresh the list
      error = nil
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  func toggleFavoriteById(_ storyId: UUID) {
    do {
      try StorageManager.shared.toggleStoryFavorite(withId: storyId)
      loadStories() // Refresh the list
      error = nil
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  // MARK: - Convenience Properties
  var favoriteStories: [Story] {
    return stories.filter { $0.isFavorite }
  }
  
  var totalStoriesCount: Int {
    return StorageManager.shared.totalStoriesCount
  }
  
  var favoriteStoriesCount: Int {
    return StorageManager.shared.favoriteStoriesCount
  }
  
  // MARK: - Recent Stories
  func getRecentStories(days: Int = 7) -> [Story] {
    do {
      return try StorageManager.shared.getRecentStories(days: days)
    } catch {
      self.error = error as? AppError ?? .dataCorruption
      return []
    }
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
