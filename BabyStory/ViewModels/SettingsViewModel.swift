import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
  @Published var profile: UserProfile?
  @Published var narrationEnabled: Bool = true
  @Published var parentalLockEnabled: Bool = false
  @Published var error: AppError?
  private let parentalPasscode = "1234" // Dummy passcode
  
  // Support URL - can be updated later
  let supportURL = URL(string: "https://taiphanvan.dev")!
  
  init() {
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
}
