import Foundation
import UIKit

@MainActor
class StoryGenerationViewModel: ObservableObject {
  @Published var options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
  @Published var isLoading = false
  @Published var isGenerating = false
  @Published var generatedStory: Story?
  @Published var error: AppError?
  @Published var autoSaveToLibrary = true
  
  // MARK: - Dependencies
  private var storyGenerationService: StoryGenerationServiceProtocol
  private let storyService: StoryServiceProtocol
  private let storyGenerationConfigService: StoryGenerationConfigServiceProtocol
  
  /// Flag indicating if a paywall needs to be shown
  @Published var showPaywall: Bool = false
  
  // MARK: - Initialization
  init(
    storyGenerationService: StoryGenerationServiceProtocol? = nil,
    storyService: StoryServiceProtocol? = nil,
    storyGenerationConfigService: StoryGenerationConfigServiceProtocol? = nil
  ) {
    self.storyGenerationService = storyGenerationService ?? ServiceFactory.shared.createStoryGenerationService(serviceType: .openAI)
    self.storyService = storyService ?? ServiceFactory.shared.createStoryService()
    self.storyGenerationConfigService = storyGenerationConfigService ?? ServiceFactory.shared.createStoryGenerationConfigService()
  }
  
  /// Updates the story generation service based on the provided config
  /// - Parameter config: The story generation configuration
  private func updateService(for config: StoryGenerationConfig) {
    let provider = config.selectedModel.provider
    let serviceType: StoryGenerationServiceType
    switch provider {
    case .openAI:
      serviceType = .openAI
    case .anthropic:
      serviceType = .claude
    case .google:
      serviceType = .gemini
    }
    storyGenerationService = ServiceFactory.shared.createStoryGenerationService(serviceType: serviceType)
  }
  
  /// Generates a story with custom options for the given user profile
  /// - Parameters:
  ///   - profile: The user profile to generate story for
  ///   - options: Custom story options, or nil to use default options
  ///   - config: The current story generation configuration
  func generateStory(profile: UserProfile, options: StoryOptions?, config: StoryGenerationConfig) async {
    Logger.info("Starting story generation", category: .storyGeneration)
    Logger.logUserProfile(profile, action: "Using for story generation")
    
    // Check if we can generate a story based on daily limits
    guard await checkStoryGenerationLimits(config: config) else {
      Logger.info("Story generation blocked due to daily limit reached", category: .storyGeneration)
      return
    }
    
    let storyOptions = options ?? self.options
    Logger.info("Generating story with theme: \(storyOptions.theme), length: \(storyOptions.length), characters: \(storyOptions.characters.joined(separator: ", "))", category: .storyGeneration)
    
    // Ensure we have the correct service for the selected model
    updateService(for: config)
    
    await performStoryGeneration { [self] in
      try await storyGenerationService.generateStory(for: profile, with: storyOptions)
    }
  }
  
  /// Generate a daily story with default options
  /// - Parameters:
  ///   - profile: The user profile to generate daily story for
  ///   - config: The current story generation configuration
  func generateDailyStory(profile: UserProfile, config: StoryGenerationConfig) async {
    Logger.info("Starting daily story generation", category: .storyGeneration)
    
    // Check if we can generate a story based on daily limits
    guard await checkStoryGenerationLimits(config: config) else {
      Logger.info("Daily story generation blocked due to daily limit reached", category: .storyGeneration)
      return
    }
    
    // Ensure we have the correct service for the selected model
    updateService(for: config)
    
    await performStoryGeneration { [self] in
      try await storyGenerationService.generateDailyStory(for: profile)
    }
  }
  
  /// Generates a custom story with the current options and profile
  /// - Parameters:
  ///   - profile: The user profile to generate story for
  ///   - appViewModel: The app view model containing the current config
  /// - Returns: The generated story if successful, nil otherwise
  func generateCustomStory(
    profile: UserProfile,
    appViewModel: AppViewModel
  ) async -> Story? {
    guard let config = appViewModel.storyGenerationConfig else {
      error = .invalidConfiguration
      return nil
    }
    
    await generateStory(profile: profile, options: options, config: config)
    
    if error != nil {
      return nil
    }
    
    // Update the app view model with the new config after successful generation
    if var updatedConfig = appViewModel.storyGenerationConfig {
      updatedConfig.incrementStoryCount()
      appViewModel.updateStoryGenerationConfig(updatedConfig)
    }
    
    return generatedStory
  }
  
  /// Generates today's story with default options
  /// - Parameters:
  ///   - profile: The user profile to generate story for
  ///   - appViewModel: The app view model containing the current config
  /// - Returns: The generated story if successful, nil otherwise
  func generateTodaysStory(
    profile: UserProfile,
    appViewModel: AppViewModel
  ) async -> Story? {
    guard let config = appViewModel.storyGenerationConfig else {
      error = .invalidConfiguration
      return nil
    }
    
    await generateDailyStory(profile: profile, config: config)
    
    if error != nil {
      return nil
    }
    
    // Update the app view model with the new config after successful generation
    if var updatedConfig = appViewModel.storyGenerationConfig {
      updatedConfig.incrementStoryCount()
      appViewModel.updateStoryGenerationConfig(updatedConfig)
    }
    
    return generatedStory
  }
  
  // MARK: - Private Helper Methods
  
  /// Performs story generation with common error handling and state management
  /// - Parameter generationBlock: The story generation closure to execute
  private func performStoryGeneration(_ generationBlock: @escaping () async throws -> Story) async {
    startGeneration()
    
    do {
      let story = try await generationBlock()
      finishGeneration(with: story)
      
      if autoSaveToLibrary {
        await autoSaveStory(story)
      }
    } catch let storyError as StoryGenerationError {
      finishGeneration(with: mapStoryGenerationError(storyError))
      Logger.error("Story generation failed: \(storyError.localizedDescription)", category: .storyGeneration)
    } catch {
      finishGeneration(with: .storyGenerationFailed)
      Logger.error("Story generation failed with unexpected error: \(error.localizedDescription)", category: .storyGeneration)
    }
  }
  
  /// Updates UI state when starting story generation
  private func startGeneration() {
    isLoading = true
    isGenerating = true
    error = nil
  }
  
  /// Updates UI state when story generation completes successfully
  /// - Parameter story: The generated story
  private func finishGeneration(with story: Story) {
    generatedStory = story
    isLoading = false
    isGenerating = false
    Logger.info("Story generation completed successfully - Title: '\(story.title)'", category: .storyGeneration)
  }
  
  /// Updates UI state when story generation fails
  /// - Parameter error: The error that occurred
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
  
  // MARK: - Subscription and Limits
  
  /// Check if story generation is allowed based on subscription limits
  /// - Parameter config: The current story generation configuration
  /// - Returns: True if story generation is allowed, false otherwise
  private func checkStoryGenerationLimits(config: StoryGenerationConfig) async -> Bool {
    var updatedConfig = config
    // Reset daily count if needed (e.g., it's a new day)
    updatedConfig.resetDailyCountIfNeeded()
    
    // Check if user can generate a new story
    if !updatedConfig.canGenerateNewStory {
      // User has reached their daily limit
      Logger.info("Daily story limit reached: \(updatedConfig.storiesGeneratedToday)/\(updatedConfig.dailyStoryLimit) stories", category: .storyGeneration)
      
      // Log detailed limit information
      Logger.info("""
        Story limit details:
        - Stories generated: \(updatedConfig.storiesGeneratedToday)
        - Daily limit: \(updatedConfig.dailyStoryLimit)
        - Subscription tier: \(updatedConfig.subscriptionTier.rawValue)
        - Last reset date: \(updatedConfig.lastResetDate)
        """, category: .storyGeneration)
      
      // Update UI to show paywall
      await MainActor.run {
        showPaywall = true
        error = .dailyStoryLimitReached
      }
      return false
    }
    
    return true
  }
}
