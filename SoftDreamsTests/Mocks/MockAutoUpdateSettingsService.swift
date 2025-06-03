//
//  MockAutoUpdateSettingsService.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
@testable import SoftDreams

class MockAutoUpdateSettingsService: AutoUpdateSettingsServiceProtocol {
    var hasInitializedSettingsResult = false
    var autoUpdateEnabledResult = true
    var stageProgressionEnabledResult = true
    var interestUpdatesEnabledResult = true
    
    var saveSettingsCalled = false
    var savedAutoUpdateEnabled: Bool?
    var savedStageProgressionEnabled: Bool?
    var savedInterestUpdatesEnabled: Bool?
    
    func hasInitializedSettings() -> Bool {
        return hasInitializedSettingsResult
    }
    
    func getAutoUpdateEnabled() -> Bool {
        return autoUpdateEnabledResult
    }
    
    func getStageProgressionEnabled() -> Bool {
        return stageProgressionEnabledResult
    }
    
    func getInterestUpdatesEnabled() -> Bool {
        return interestUpdatesEnabledResult
    }
    
    func saveSettings(autoUpdate: Bool, stageProgression: Bool, interestUpdates: Bool) {
        saveSettingsCalled = true
        savedAutoUpdateEnabled = autoUpdate
        savedStageProgressionEnabled = stageProgression
        savedInterestUpdatesEnabled = interestUpdates
    }
    
    func markAsInitialized() {
        hasInitializedSettingsResult = true
    }
}
