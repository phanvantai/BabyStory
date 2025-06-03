import Foundation

class LibraryViewModel: ObservableObject {
  @Published var stories: [Story] = []
  @Published var error: AppError?
  
  // MARK: - Initialization
  private let storyService: StoryServiceProtocol
  
  init(storyService: StoryServiceProtocol? = nil) {
    self.storyService = storyService ?? ServiceFactory.shared.createStoryService()
    loadStories()
  }
  
  func loadStories() {
    do {
      stories = try storyService.loadStories()
      error = nil
    } catch {
      self.error = error as? AppError ?? .dataCorruption
    }
  }
  
  func toggleFavorite(for story: Story) {
    do {
      if let index = stories.firstIndex(where: { $0.id == story.id }) {
        stories[index].isFavorite.toggle()
        try storyService.saveStories(stories)
        error = nil
      }
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  // MARK: - Enhanced Storage Methods
  func deleteStory(_ story: Story) {
    do {
      try storyService.deleteStory(withId: story.id.uuidString)
      loadStories() // Refresh the list
      error = nil
    } catch {
      self.error = .storySaveFailed
    }
  }
  
  func saveStory(_ story: Story) {
    do {
      try storyService.saveStory(story)
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
    return (try? storyService.getStoryCount()) ?? 0
  }
  
  var favoriteStoriesCount: Int {
    return favoriteStories.count
  }
}
