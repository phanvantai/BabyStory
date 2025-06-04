import Foundation

// MARK: - Service Factory
/// Factory class for creating service instances
/// This allows easy switching between different implementations (UserDefaults, Core Data, CloudKit, etc.)
class ServiceFactory {
  
  // MARK: - Singleton
  static let shared = ServiceFactory()
  private init() {}
  
  // MARK: - Service Creation
  
  /// Create a user profile service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to UserProfileServiceProtocol
  func createUserProfileService() -> UserProfileServiceProtocol {
    return UserDefaultsUserProfileService()
  }
  
  /// Create a story service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to StoryServiceProtocol
  func createStoryService() -> StoryServiceProtocol {
    return CoreDataStoryService()
  }
  
  /// Create a theme service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to ThemeServiceProtocol
  func createThemeService() -> ThemeServiceProtocol {
    return UserDefaultsThemeService()
  }
  
  /// Create a due date notification service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A DueDateNotificationService instance
  func createDueDateNotificationService() -> DueDateNotificationService {
    let userProfileService = createUserProfileService()
    return DueDateNotificationService(userProfileService: userProfileService)
  }
  
  /// Create an auto profile update service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to AutoProfileUpdateServiceProtocol
  func createAutoProfileUpdateService() -> AutoProfileUpdateServiceProtocol {
    let userProfileService = createUserProfileService()
    let notificationService = createDueDateNotificationService()
    return AutoProfileUpdateService(userProfileService: userProfileService, notificationService: notificationService)
  }
  
  /// Create an auto update settings service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to AutoUpdateSettingsServiceProtocol
  func createAutoUpdateSettingsService() -> AutoUpdateSettingsServiceProtocol {
    return UserDefaultsAutoUpdateSettingsService()
  }
  
  /// Create a story time notification service instance
  /// - Returns: A service conforming to StoryTimeNotificationServiceProtocol
  func createStoryTimeNotificationService() -> StoryTimeNotificationServiceProtocol {
    return StoryTimeNotificationService()
  }
  
  /// Create a story generation config service instance
  /// - Returns: A service conforming to StoryGenerationConfigServiceProtocol
  func createStoryGenerationConfigService() -> StoryGenerationConfigServiceProtocol {
    return UserDefaultsStoryGenerationConfigService()
  }
  
  /// Create a story generation service instance
  /// - Parameter serviceType: The type of story generation service to use
  /// - Returns: A service conforming to StoryGenerationServiceProtocol
  func createStoryGenerationService(serviceType: StoryGenerationServiceType = .openAI) -> StoryGenerationServiceProtocol {
    switch serviceType {
      case .openAI:
        // Try to create OpenAI service with stored API key
        if let openAIService = OpenAIStoryGenerationService.createWithStoredAPIKey() {
          return openAIService
        } else {
          // Fallback to mock service if no API key is available
          Logger.info("OpenAI API key not available, falling back to mock service", category: .storyGeneration)
          fatalError("OpenAI API key not available, please set it in settings or use mock service")
        }
      case .claude:
        // Try to create Claude service with stored API key
        if let claudeService = AnthropicClaudeStoryGenerationService.createWithStoredAPIKey() {
          return claudeService
        } else {
          // Fallback to mock service if no API key is available
          Logger.info("Claude API key not available, falling back to mock service", category: .storyGeneration)
          fatalError("Claude API key not available, please set it in settings or use mock service")
        }
      case .gemini:
        // fatal error for Gemini as it's not implemented yet
        fatalError("Gemini story generation service not implemented yet")
    }
  }
}

// MARK: - Story Generation Service Type Enum
enum StoryGenerationServiceType {
  case openAI
  case claude
  case gemini
}
