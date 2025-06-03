import Foundation

class StoryGenerationViewModel: ObservableObject {
  @Published var options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
  @Published var isLoading = false
  @Published var isGenerating = false
  @Published var generatedStory: Story?
  @Published var error: AppError?
  @Published var autoSaveToLibrary = true
  
  // MARK: - Dependencies
  private let storyGenerationService: StoryGenerationServiceProtocol
  private let storyService: StoryServiceProtocol
  
  // MARK: - Initialization
  init(storyGenerationService: StoryGenerationServiceProtocol? = nil, storyService: StoryServiceProtocol? = nil) {
    self.storyGenerationService = storyGenerationService ?? ServiceFactory.shared.createStoryGenerationService(serviceType: .openAI)
    self.storyService = storyService ?? ServiceFactory.shared.createStoryService()
  }
  
  /// Generates a story with custom options for the given user profile
  /// - Parameters:
  ///   - profile: The user profile to generate story for
  ///   - options: Custom story options, or nil to use default options
  func generateStory(profile: UserProfile, options: StoryOptions?) async {
    Logger.info("Starting story generation", category: .storyGeneration)
    Logger.logUserProfile(profile, action: "Using for story generation")
    
    let storyOptions = options ?? self.options
    Logger.info("Generating story with theme: \(storyOptions.theme), length: \(storyOptions.length), characters: \(storyOptions.characters.joined(separator: ", "))", category: .storyGeneration)
    
    await performStoryGeneration { [self] in
      try await storyGenerationService.generateStory(for: profile, with: storyOptions)
    }
  }
  
  /// Generate a daily story with default options
  /// - Parameter profile: The user profile to generate daily story for
  func generateDailyStory(profile: UserProfile) async {
    Logger.info("Starting daily story generation", category: .storyGeneration)
    
    await performStoryGeneration { [self] in
      try await storyGenerationService.generateDailyStory(for: profile)
    }
  }
  
  // MARK: - Private Helper Methods
  
  /// Performs story generation with common error handling and state management
  /// - Parameter generationBlock: The story generation closure to execute
  private func performStoryGeneration(_ generationBlock: @escaping () async throws -> Story) async {
    await startGeneration()
    
    do {
      let story = try await generationBlock()
      await finishGeneration(with: story)
      
      if autoSaveToLibrary {
        await autoSaveStory(story)
      }
    } catch let storyError as StoryGenerationError {
      await finishGeneration(with: mapStoryGenerationError(storyError))
      Logger.error("Story generation failed: \(storyError.localizedDescription)", category: .storyGeneration)
    } catch {
      await finishGeneration(with: .storyGenerationFailed)
      Logger.error("Story generation failed with unexpected error: \(error.localizedDescription)", category: .storyGeneration)
    }
  }
  
  /// Updates UI state when starting story generation
  @MainActor
  private func startGeneration() {
    isLoading = true
    isGenerating = true
    error = nil
  }
  
  /// Updates UI state when story generation completes successfully
  /// - Parameter story: The generated story
  @MainActor
  private func finishGeneration(with story: Story) {
    generatedStory = story
    isLoading = false
    isGenerating = false
    Logger.info("Story generation completed successfully - Title: '\(story.title)'", category: .storyGeneration)
  }
  
  /// Updates UI state when story generation fails
  /// - Parameter error: The error that occurred
  @MainActor
  private func finishGeneration(with error: AppError) {
    self.error = error
    isLoading = false
    isGenerating = false
  }
  
  /// Auto-save story to library if enabled
  /// - Parameter story: The story to save
  private func autoSaveStory(_ story: Story) async {
    do {
      try storyService.saveStory(story)
      Logger.info("Story auto-saved to library successfully - Title: '\(story.title)'", category: .storyGeneration)
    } catch {
      await MainActor.run {
        Logger.error("Failed to auto-save story to library: \(error.localizedDescription)", category: .storyGeneration)
        self.error = error as? AppError ?? .storySaveFailed
      }
    }
  }
  
  /// Maps story generation errors to app errors
  /// - Parameter storyError: The story generation error to map
  /// - Returns: The corresponding app error
  
  private func mapStoryGenerationError(_ storyError: StoryGenerationError) -> AppError {
    switch storyError {
    case .invalidProfile:
      return .invalidProfile
    case .invalidOptions:
      return .invalidStoryOptions
    case .generationFailed:
      return .storyGenerationFailed
    case .networkError:
      return .networkUnavailable
    case .quotaExceeded:
      return .storyGenerationFailed // Map to closest AppError equivalent
    case .serviceUnavailable:
      return .networkUnavailable
    }
  }
}
