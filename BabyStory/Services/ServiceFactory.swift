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
  func createUserProfileService(storageType: StorageType = .userDefaults) -> UserProfileServiceProtocol {
    switch storageType {
    case .userDefaults:
      return UserDefaultsUserProfileService()
    case .coreData:
      // TODO: Implement Core Data service
      fatalError("Core Data not implemented yet")
    case .cloudKit:
      // TODO: Implement CloudKit service
      fatalError("CloudKit not implemented yet")
    }
  }
  
  /// Create a story service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to StoryServiceProtocol
  func createStoryService(storageType: StorageType = .userDefaults) -> StoryServiceProtocol {
    switch storageType {
    case .userDefaults:
      return UserDefaultsStoryService()
    case .coreData:
      // TODO: Implement Core Data service
      fatalError("Core Data not implemented yet")
    case .cloudKit:
      // TODO: Implement CloudKit service
      fatalError("CloudKit not implemented yet")
    }
  }
  
  /// Create a theme service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to ThemeServiceProtocol
  func createThemeService(storageType: StorageType = .userDefaults) -> ThemeServiceProtocol {
    switch storageType {
    case .userDefaults:
      return UserDefaultsThemeService()
    case .coreData:
      // TODO: Implement Core Data service
      fatalError("Core Data not implemented yet")
    case .cloudKit:
      // TODO: Implement CloudKit service
      fatalError("CloudKit not implemented yet")
    }
  }
  
  /// Create a settings service instance
  /// - Parameter storageType: The type of storage to use
  /// - Returns: A service conforming to SettingsServiceProtocol
  func createSettingsService(storageType: StorageType = .userDefaults) -> SettingsServiceProtocol {
    switch storageType {
    case .userDefaults:
      return UserDefaultsSettingsService()
    case .coreData:
      // TODO: Implement Core Data service
      fatalError("Core Data not implemented yet")
    case .cloudKit:
      // TODO: Implement CloudKit service
      fatalError("CloudKit not implemented yet")
    }
  }
}

// MARK: - Storage Type Enum
enum StorageType {
  case userDefaults
  case coreData
  case cloudKit
}
