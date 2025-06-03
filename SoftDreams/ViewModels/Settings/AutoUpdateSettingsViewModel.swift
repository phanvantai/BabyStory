//
//  AutoUpdateSettingsViewModel.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation

class AutoUpdateSettingsViewModel: ObservableObject {
  // MARK: - Published Properties
  @Published var autoUpdateEnabled: Bool {
    didSet {
      settingsService.saveAutoUpdateEnabled(autoUpdateEnabled)
    }
  }
  
  @Published var stageProgressionEnabled: Bool {
    didSet {
      settingsService.saveStageProgressionEnabled(stageProgressionEnabled)
    }
  }
  
  @Published var interestUpdatesEnabled: Bool {
    didSet {
      settingsService.saveInterestUpdatesEnabled(interestUpdatesEnabled)
    }
  }
  
  @Published var isCheckingForUpdates = false
  @Published var showUpdateResult = false
  @Published var updateResultMessage = ""
  
  // MARK: - Dependencies
  private let settingsService: AutoUpdateSettingsServiceProtocol
  private let autoUpdateService: AutoProfileUpdateServiceProtocol
  private let userProfileService: UserProfileServiceProtocol
  
  // MARK: - Computed Properties
  var lastUpdateInfo: String? {
    do {
      if let profile = try userProfileService.loadProfile() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return String(format: "auto_update_last_updated_format".localized, formatter.string(from: profile.lastUpdate))
      }
    } catch {
      Logger.error("Failed to get last update info: \(error.localizedDescription)", category: .settings)
    }
    return nil
  }
  
  // MARK: - Initialization
  init(
    settingsService: AutoUpdateSettingsServiceProtocol? = nil,
    autoUpdateService: AutoProfileUpdateServiceProtocol? = nil,
    userProfileService: UserProfileServiceProtocol? = nil
  ) {
    self.settingsService = settingsService ?? ServiceFactory.shared.createAutoUpdateSettingsService()
    self.autoUpdateService = autoUpdateService ?? ServiceFactory.shared.createAutoProfileUpdateService()
    self.userProfileService = userProfileService ?? ServiceFactory.shared.createUserProfileService()
    
    // Check if this is the first time setup
    if !self.settingsService.hasInitializedSettings() {
      // Set user-friendly defaults for first-time users
      self.autoUpdateEnabled = true
      self.stageProgressionEnabled = true
      self.interestUpdatesEnabled = true
      
      // Save the default settings
      self.settingsService.saveSettings(
        autoUpdate: true,
        stageProgression: true,
        interestUpdates: true
      )
      self.settingsService.markAsInitialized()
    } else {
      // Load existing settings
      self.autoUpdateEnabled = self.settingsService.isAutoUpdateEnabled()
      self.stageProgressionEnabled = self.settingsService.isStageProgressionEnabled()
      self.interestUpdatesEnabled = self.settingsService.isInterestUpdatesEnabled()
    }
  }
  
  // MARK: - Public Methods
  @MainActor
  func performManualUpdate() async {
    isCheckingForUpdates = true
    updateResultMessage = ""
    
    // Ensure we have a profile before attempting updates
    guard let currentProfile = try? userProfileService.loadProfile() else {
      updateResultMessage = "auto_update_no_profile_message".localized
      isCheckingForUpdates = false
      showUpdateResult = true
      return
    }
    
    let result = await autoUpdateService.performAutoUpdate(profile: currentProfile)
    
    if result.isSuccess {
      if result.hasUpdates {
        updateResultMessage = String(format: "auto_update_success_message".localized, result.updateCount)
      } else {
        updateResultMessage = "auto_update_no_updates_message".localized
      }
    } else {
      updateResultMessage = "auto_update_failed_message".localized
    }
    
    isCheckingForUpdates = false
    showUpdateResult = true
  }
}
