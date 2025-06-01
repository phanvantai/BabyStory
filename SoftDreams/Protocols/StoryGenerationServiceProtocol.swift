import Foundation

// MARK: - Story Generation Service Protocol
/// Handles story generation logic and AI-powered content creation
protocol StoryGenerationServiceProtocol {
  /// Generate a personalized story based on user profile and options
  /// - Parameters:
  ///   - profile: The user profile containing child information
  ///   - options: Story generation options (theme, length, characters, etc.)
  /// - Returns: A generated Story object
  /// - Throws: StoryGenerationError if generation fails
  func generateStory(for profile: UserProfile, with options: StoryOptions) async throws -> Story
  
  /// Generate a quick daily story with default options
  /// - Parameter profile: The user profile containing child information
  /// - Returns: A generated Story object
  /// - Throws: StoryGenerationError if generation fails
  func generateDailyStory(for profile: UserProfile) async throws -> Story
  
  /// Validate if story generation is possible with given parameters
  /// - Parameters:
  ///   - profile: The user profile to validate
  ///   - options: Story options to validate
  /// - Returns: True if generation is possible, false otherwise
  func canGenerateStory(for profile: UserProfile, with options: StoryOptions) -> Bool
  
  /// Get suggested themes based on user profile
  /// - Parameter profile: The user profile
  /// - Returns: Array of suggested theme strings
  func getSuggestedThemes(for profile: UserProfile) -> [String]
  
  /// Get estimated generation time for a story
  /// - Parameter options: Story options to estimate for
  /// - Returns: Estimated time interval in seconds
  func getEstimatedGenerationTime(for options: StoryOptions) -> TimeInterval
}

// MARK: - Story Generation Error
enum StoryGenerationError: Error, LocalizedError {
  case invalidProfile
  case invalidOptions
  case generationFailed
  case networkError
  case quotaExceeded
  case serviceUnavailable
  
  var errorDescription: String? {
    switch self {
    case .invalidProfile:
      return "Invalid profile provided for story generation"
    case .invalidOptions:
      return "Invalid story options provided"
    case .generationFailed:
      return "Failed to generate story content"
    case .networkError:
      return "Network error during story generation"
    case .quotaExceeded:
      return "Story generation quota exceeded"
    case .serviceUnavailable:
      return "Story generation service is currently unavailable"
    }
  }
}
