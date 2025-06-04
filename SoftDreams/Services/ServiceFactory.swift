import Foundation
import UIKit

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
  
  /// Create a StoreKit service instance
  /// - Returns: A StoreKitService instance
  @MainActor func createStoreKitService() -> StoreKitService {
    return StoreKitService()
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
  
  /// Create a story generation config service instance
  /// - Returns: A service conforming to StoryGenerationConfigServiceProtocol
  func createStoryGenerationConfigService() -> StoryGenerationConfigServiceProtocol {
    return UserDefaultsStoryGenerationConfigService()
  }
  
  /// Create a story generation service instance
  /// - Parameter serviceType: The type of story generation service to use
  /// - Returns: A service conforming to StoryGenerationServiceProtocol
  @MainActor
  func createStoryGenerationService(serviceType: StoryGenerationServiceType = .openAI) -> StoryGenerationServiceProtocol {
    // Get current config from AppViewModel or load from service
    let config: StoryGenerationConfig
    
    if let appVM = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appViewModel,
       let appConfig = appVM.storyGenerationConfig {
      config = appConfig
    } else {
      // Load config from service if AppViewModel is not available
      Logger.warning("AppViewModel not available, loading config from service", category: .storyGeneration)
      do {
        config = try createStoryGenerationConfigService().loadConfig()
      } catch {
        Logger.error("Failed to load story generation config: \(error.localizedDescription)", category: .storyGeneration)
        fatalError("Failed to load story generation config: \(error.localizedDescription)")
      }
    }
    
    let selectedModel = config.selectedModel
    
    // Check API key availability first
    switch serviceType {
      case .openAI:
        guard !APIConfig.openAIAPIKey.isEmpty else {
          Logger.error("OpenAI API key not available", category: .storyGeneration)
          fatalError("OpenAI API key not available, please set it in settings")
        }
        return OpenAIStoryGenerationService(
          apiKey: APIConfig.openAIAPIKey,
          model: selectedModel.rawValue,
          maxTokens: selectedModel.maxTokens,
          temperature: selectedModel.temperature
        )
        
      case .claude:
        guard !APIConfig.anthropicAPIKey.isEmpty else {
          Logger.error("Claude API key not available", category: .storyGeneration)
          fatalError("Claude API key not available, please set it in settings")
        }
        return AnthropicClaudeStoryGenerationService(
          apiKey: APIConfig.anthropicAPIKey,
          model: selectedModel.rawValue,
          maxTokens: selectedModel.maxTokens,
          temperature: selectedModel.temperature
        )
        
      case .gemini:
        // fatal error for Gemini as it's not implemented yet
        fatalError("Gemini story generation service not implemented yet")
    }
  }
  
  /// Create a story time notification service instance
  /// - Returns: A service conforming to StoryTimeNotificationServiceProtocol
  func createStoryTimeNotificationService() -> StoryTimeNotificationServiceProtocol {
    return StoryTimeNotificationService()
  }
}

// MARK: - Story Generation Service Type Enum
enum StoryGenerationServiceType {
  case openAI
  case claude
  case gemini
}
