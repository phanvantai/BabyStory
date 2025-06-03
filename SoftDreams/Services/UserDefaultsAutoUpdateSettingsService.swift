//
//  UserDefaultsAutoUpdateSettingsService.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation

/// UserDefaults-based implementation of auto update settings management
class UserDefaultsAutoUpdateSettingsService: AutoUpdateSettingsServiceProtocol {
    
    private struct Keys {
        static let initialized = "auto_update_settings_initialized"
        static let autoUpdateEnabled = "auto_update_enabled"
        static let stageProgressionEnabled = "stage_progression_enabled"
        static let interestUpdatesEnabled = "interest_updates_enabled"
    }
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func hasInitializedSettings() -> Bool {
        return userDefaults.object(forKey: Keys.initialized) != nil
    }
    
    func getAutoUpdateEnabled() -> Bool {
        return userDefaults.bool(forKey: Keys.autoUpdateEnabled)
    }
    
    func getStageProgressionEnabled() -> Bool {
        return userDefaults.bool(forKey: Keys.stageProgressionEnabled)
    }
    
    func getInterestUpdatesEnabled() -> Bool {
        return userDefaults.bool(forKey: Keys.interestUpdatesEnabled)
    }
    
    func saveSettings(autoUpdate: Bool, stageProgression: Bool, interestUpdates: Bool) {
        userDefaults.set(autoUpdate, forKey: Keys.autoUpdateEnabled)
        userDefaults.set(stageProgression, forKey: Keys.stageProgressionEnabled)
        userDefaults.set(interestUpdates, forKey: Keys.interestUpdatesEnabled)
    }
    
    func markAsInitialized() {
        userDefaults.set(true, forKey: Keys.initialized)
    }
}
