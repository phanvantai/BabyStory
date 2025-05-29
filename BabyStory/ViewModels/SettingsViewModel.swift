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
    do {
      profile = try StorageManager.shared.loadProfile()
      error = nil
    } catch {
      self.error = error as? AppError ?? .dataCorruption
    }
  }
  
  func loadSettings() {
    // Load settings using the new storage manager
    narrationEnabled = StorageManager.shared.loadNarrationEnabled()
    parentalLockEnabled = StorageManager.shared.loadParentalLockEnabled()
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
  
  // MARK: - Data Management
  func exportData() -> Data? {
    do {
      return try StorageManager.shared.exportData()
    } catch {
      self.error = .dataExportFailed
      return nil
    }
  }
  
  func importData(_ data: Data) {
    do {
      try StorageManager.shared.importData(data)
      // Refresh all data after import
      loadProfile()
      loadSettings()
      error = nil
    } catch {
      self.error = .dataImportFailed
    }
  }
  
  func clearAllData() {
    do {
      try StorageManager.shared.clearAllData()
      // Reset local state
      profile = nil
      narrationEnabled = true
      parentalLockEnabled = false
      error = nil
    } catch {
      self.error = .dataSaveFailed
    }
  }
  
  func validateDataIntegrity() -> Bool {
    do {
      return try StorageManager.shared.validateDataIntegrity()
    } catch {
      self.error = error as? AppError ?? .dataCorruption
      return false
    }
  }
}
