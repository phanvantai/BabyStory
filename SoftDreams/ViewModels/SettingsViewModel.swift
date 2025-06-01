import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
  @Published var profile: UserProfile?
  @Published var narrationEnabled: Bool = true
  @Published var parentalLockEnabled: Bool = false
  @Published var error: AppError?
  private let parentalPasscode = "1234" // Dummy passcode
  
  // App info properties
  @Published var appName: String
  @Published var appVersion: String
  
  // Support URL - can be updated later
  let supportURL = URL(string: "https://taiphanvan.dev")!
  
  // App info service
  private let appInfo = AppInfoService.shared
  
  init() {
    // Initialize app info properties
    self.appName = appInfo.appName
    self.appVersion = appInfo.appVersion
    
    loadProfile()
    loadSettings()
  }
  
  func loadProfile() {
    Logger.info("Loading profile in settings", category: .settings)
    do {
      profile = try StorageManager.shared.loadProfile()
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
    // Load settings using the new storage manager
    //    narrationEnabled = StorageManager.shared.loadNarrationEnabled()
    //    parentalLockEnabled = StorageManager.shared.loadParentalLockEnabled()
  }
  
  func saveProfile(_ profile: UserProfile) {
    do {
      self.profile = profile
      try StorageManager.shared.saveProfile(profile)
      error = nil
    } catch {
      self.error = .profileSaveFailed
    }
  }
  
  func toggleParentalLock(passcode: String) -> Bool {
    if passcode == parentalPasscode {
      parentalLockEnabled.toggle()
      return true
    }
    return false
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
      try StorageManager.shared.saveNarrationEnabled(enabled)
      error = nil
    } catch {
      self.error = .dataSaveFailed
    }
  }
  
  func saveParentalLockEnabled(_ enabled: Bool) {
    do {
      parentalLockEnabled = enabled
      try StorageManager.shared.saveParentalLockEnabled(enabled)
      error = nil
    } catch {
      self.error = .dataSaveFailed
    }
  }
  
  func saveParentalPasscode(_ passcode: String) {
    do {
      try StorageManager.shared.saveParentalPasscode(passcode)
      error = nil
    } catch {
      self.error = .dataSaveFailed
    }
  }
  
  // MARK: - Notification Permission Methods
  
  /// Handles when user grants notification permission from Settings
  func handleNotificationPermissionGranted() async {
    Task {
      let notificationService = ServiceFactory.shared.createDueDateNotificationService()
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
