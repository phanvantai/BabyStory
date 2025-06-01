import Foundation

// MARK: - Story Service Protocol
/// Handles story data persistence and management
protocol StoryServiceProtocol {
  /// Save multiple stories to storage
  /// - Parameter stories: Array of stories to save
  /// - Throws: Storage error if save operation fails
  func saveStories(_ stories: [Story]) throws
  
  /// Load all stories from storage
  /// - Returns: Array of saved stories
  /// - Throws: Storage error if load operation fails
  func loadStories() throws -> [Story]
  
  /// Save a single story to storage
  /// - Parameter story: The story to save
  /// - Throws: Storage error if save operation fails
  func saveStory(_ story: Story) throws
  
  /// Delete a story by its ID
  /// - Parameter id: The unique identifier of the story to delete
  /// - Throws: Storage error if delete operation fails
  func deleteStory(withId id: String) throws
  
  /// Update an existing story
  /// - Parameter story: The updated story
  /// - Throws: Storage error if update operation fails
  func updateStory(_ story: Story) throws
  
  /// Get a specific story by ID
  /// - Parameter id: The unique identifier of the story
  /// - Returns: The story if found, nil otherwise
  /// - Throws: Storage error if load operation fails
  func getStory(withId id: String) throws -> Story?
  
  /// Search stories by criteria
  /// - Parameter searchTerm: Text to search for in story titles and content
  /// - Returns: Array of matching stories
  /// - Throws: Storage error if search operation fails
  //  func searchStories(containing searchTerm: String) throws -> [Story]
  
  /// Get stories by category or theme
  /// - Parameter theme: The theme to filter by
  /// - Returns: Array of stories matching the theme
  /// - Throws: Storage error if load operation fails
  //  func getStories(byTheme theme: String) throws -> [Story]
  
  /// Get the total number of saved stories
  /// - Returns: Count of saved stories
  /// - Throws: Storage error if count operation fails
  func getStoryCount() throws -> Int
}
