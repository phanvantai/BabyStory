import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
  @Published var profile: UserProfile?
  @Published var narrationEnabled: Bool = true
  @Published var error: AppError?
  
  // App info properties
  @Published var appName: String
  @Published var appVersion: String
  
  // Support URL - can be updated later
  let supportURL = URL(string: "https://taiphanvan.dev")!
  
  // Injected services
  private let userProfileService: UserProfileServiceProtocol
  private let settingsService: SettingsServiceProtocol
  private let notificationService: DueDateNotificationService
  
  // App info service
  private let appInfo = AppInfoService.shared
  
  init(
    userProfileService: UserProfileServiceProtocol? = nil,
    settingsService: SettingsServiceProtocol? = nil,
    notificationService: DueDateNotificationService? = nil
  ) {
    // Initialize services with dependency injection
    self.userProfileService = userProfileService ?? ServiceFactory.shared.createUserProfileService()
    self.settingsService = settingsService ?? ServiceFactory.shared.createSettingsService()
    self.notificationService = notificationService ?? ServiceFactory.shared.createDueDateNotificationService()
    
    // Initialize app info properties
    self.appName = appInfo.appName
    self.appVersion = appInfo.appVersion
    
    loadProfile()
    loadSettings()
  }
  
  func loadProfile() {
    Logger.info("Loading profile in settings", category: .settings)
    do {
      profile = try userProfileService.loadProfile()
      error = nil
      
      if let profile = profile {
        Logger.info("Settings profile loaded for: \(profile.name)", category: .settings)
      } else {
        Logger.warning("No profile found in settings", category: .settings)
      }
    } catch {
      Logger.error("Failed to load profile in settings: \(error.localizedDescription)", category: .settings)
      self.error = error as? AppError ?? .dataCorruption
    }
  }
  
  func loadSettings() {
    Logger.info("Loading settings", category: .settings)
    do {
      narrationEnabled = try settingsService.loadSetting(Bool.self, forKey: StorageKeys.narrationEnabled) ?? true
      error = nil
    } catch {
      Logger.error("Failed to load settings: \(error.localizedDescription)", category: .settings)
      self.error = error as? AppError ?? .dataCorruption
    }
  }
  
  func saveProfile(_ profile: UserProfile) {
    do {
      self.profile = profile
      try userProfileService.saveProfile(profile)
      error = nil
    } catch {
      self.error = .profileSaveFailed
    }
  }

  // Open URL in default browser
  func openSupportWebsite() {
    if UIApplication.shared.canOpenURL(supportURL) {
      UIApplication.shared.open(supportURL)
    }
  }
  
  // MARK: - Settings Management
  func saveNarrationEnabled(_ enabled: Bool) {
    do {
      narrationEnabled = enabled
      try settingsService.saveSetting(enabled, forKey: StorageKeys.narrationEnabled)
      error = nil
    } catch {
      self.error = .dataSaveFailed
    }
  }

  // MARK: - Notification Permission Methods
  
  /// Handles when user grants notification permission from Settings
  func handleNotificationPermissionGranted() async {
    Task {
      let success = await notificationService.requestNotificationPermission()
      
      if success {
        Logger.info("Notifications enabled from Settings - due date notifications set up", category: .notification)
      } else {
        Logger.warning("Failed to set up notifications from Settings", category: .notification)
      }
    }
  }
  
  /// Handles when user denies notification permission from Settings
  func handleNotificationPermissionDenied() {
    Logger.info("User declined notifications from Settings", category: .notification)
    // User can always enable notifications later from Settings or iOS Settings
  }
}
