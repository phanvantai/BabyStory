import Foundation

// MARK: - UserDefaults Story Service
/// UserDefaults implementation of StoryServiceProtocol
class UserDefaultsStoryService: StoryServiceProtocol {
  
  // MARK: - Properties
  private let defaults = UserDefaults.standard
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  
  // MARK: - StoryServiceProtocol Implementation
  
  func saveStories(_ stories: [Story]) throws {
    do {
      let data = try encoder.encode(stories)
      defaults.set(data, forKey: StorageKeys.savedStories)
    } catch {
      throw AppError.storySaveFailed
    }
  }
  
  func loadStories() throws -> [Story] {
    guard let data = defaults.data(forKey: StorageKeys.savedStories) else {
      return []
    }
    do {
      return try decoder.decode([Story].self, from: data)
    } catch {
      throw AppError.dataCorruption
    }
  }
  
  func saveStory(_ story: Story) throws {
    var stories = try loadStories()
    
    // Remove existing story with same ID if it exists
    stories.removeAll { $0.id == story.id }
    
    // Add the new/updated story
    stories.append(story)
    
    try saveStories(stories)
  }
  
  func deleteStory(withId id: String) throws {
    var stories = try loadStories()
    stories.removeAll { $0.id.uuidString == id }
    try saveStories(stories)
  }
  
  func updateStory(_ story: Story) throws {
    try saveStory(story) // This handles both insert and update
  }
  
  func getStory(withId id: String) throws -> Story? {
    let stories = try loadStories()
    return stories.first { $0.id.uuidString == id }
  }
  
  func searchStories(containing searchTerm: String) throws -> [Story] {
    let stories = try loadStories()
    return stories.filter { story in
      story.title.localizedCaseInsensitiveContains(searchTerm) ||
      story.content.localizedCaseInsensitiveContains(searchTerm)
    }
  }
  
  func getStoryCount() throws -> Int {
    return try loadStories().count
  }
}
