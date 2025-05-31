import Foundation

class StoryGenerationViewModel: ObservableObject {
  @Published var options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
  @Published var isLoading = false
  @Published var isGenerating = false
  @Published var generatedStory: Story?
  @Published var error: AppError?
  
  // MARK: - Dependencies
  private let storyGenerationService: StoryGenerationServiceProtocol
  
  // MARK: - Initialization
  init(storyGenerationService: StoryGenerationServiceProtocol? = nil) {
    self.storyGenerationService = storyGenerationService ?? ServiceFactory.shared.createStoryGenerationService()
  }
  
  func generateStory(profile: UserProfile, options: StoryOptions?) async {
    Logger.info("Starting story generation", category: .storyGeneration)
    Logger.logUserProfile(profile, action: "Using for story generation")
    
    await MainActor.run {
      self.isLoading = true
      self.isGenerating = true
      self.error = nil
    }
    
    do {
      let storyOptions = options ?? self.options
      Logger.info("Generating story with theme: \(storyOptions.theme), length: \(storyOptions.length), characters: \(storyOptions.characters.joined(separator: ", "))", category: .storyGeneration)
      
      let story = try await storyGenerationService.generateStory(for: profile, with: storyOptions)
      
      await MainActor.run {
        self.generatedStory = story
        self.isLoading = false
        self.isGenerating = false
        Logger.info("Story generation completed successfully - Title: '\(story.title)'", category: .storyGeneration)
      }
    } catch let storyError as StoryGenerationError {
      await MainActor.run {
        Logger.error("Story generation failed: \(storyError.localizedDescription)", category: .storyGeneration)
        self.error = mapStoryGenerationError(storyError)
        self.isLoading = false
        self.isGenerating = false
      }
    } catch {
      await MainActor.run {
        Logger.error("Story generation failed with unexpected error: \(error.localizedDescription)", category: .storyGeneration)
        self.error = .storyGenerationFailed
        self.isLoading = false
        self.isGenerating = false
      }
    }
  }
  
  /// Generate a daily story with default options
  func generateDailyStory(profile: UserProfile) async {
    Logger.info("Starting daily story generation", category: .storyGeneration)
    
    await MainActor.run {
      self.isLoading = true
      self.isGenerating = true
      self.error = nil
    }
    
    do {
      let story = try await storyGenerationService.generateDailyStory(for: profile)
      
      await MainActor.run {
        self.generatedStory = story
        self.isLoading = false
        self.isGenerating = false
        Logger.info("Daily story generation completed successfully - Title: '\(story.title)'", category: .storyGeneration)
      }
    } catch let storyError as StoryGenerationError {
      await MainActor.run {
        Logger.error("Daily story generation failed: \(storyError.localizedDescription)", category: .storyGeneration)
        self.error = mapStoryGenerationError(storyError)
        self.isLoading = false
        self.isGenerating = false
      }
    } catch {
      await MainActor.run {
        Logger.error("Daily story generation failed with unexpected error: \(error.localizedDescription)", category: .storyGeneration)
        self.error = .storyGenerationFailed
        self.isLoading = false
        self.isGenerating = false
      }
    }
  }
  
  /// Get suggested themes based on current profile
  func getSuggestedThemes(for profile: UserProfile) -> [String] {
    return storyGenerationService.getSuggestedThemes(for: profile)
  }
  
  /// Get estimated generation time for current options
  func getEstimatedGenerationTime() -> TimeInterval {
    return storyGenerationService.getEstimatedGenerationTime(for: options)
  }
  
  /// Check if story generation is possible with current settings
  func canGenerateStory(for profile: UserProfile) -> Bool {
    return storyGenerationService.canGenerateStory(for: profile, with: options)
  }
  
  // MARK: - Private Helper Methods
  
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
