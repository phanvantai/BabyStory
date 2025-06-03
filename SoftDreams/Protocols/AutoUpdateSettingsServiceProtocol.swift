//
//  AutoUpdateSettingsServiceProtocol.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation

/// Protocol for managing auto update settings persistence
protocol AutoUpdateSettingsServiceProtocol {
    /// Check if settings have been initialized before
    func hasInitializedSettings() -> Bool
    
    /// Get the current auto update enabled state
    func getAutoUpdateEnabled() -> Bool
    
    /// Get the current stage progression enabled state
    func getStageProgressionEnabled() -> Bool
    
    /// Get the current interest updates enabled state
    func getInterestUpdatesEnabled() -> Bool
    
    /// Save all auto update settings
    func saveSettings(autoUpdate: Bool, stageProgression: Bool, interestUpdates: Bool)
    
    /// Mark settings as initialized
    func markAsInitialized()
    
    // MARK: - Individual Setting Methods (for View Model convenience)
    
    /// Check if auto update is enabled (convenience method)
    func isAutoUpdateEnabled() -> Bool
    
    /// Check if stage progression is enabled (convenience method)
    func isStageProgressionEnabled() -> Bool
    
    /// Check if interest updates is enabled (convenience method)
    func isInterestUpdatesEnabled() -> Bool
    
    /// Save auto update enabled state
    func saveAutoUpdateEnabled(_ enabled: Bool)
    
    /// Save stage progression enabled state
    func saveStageProgressionEnabled(_ enabled: Bool)
    
    /// Save interest updates enabled state
    func saveInterestUpdatesEnabled(_ enabled: Bool)
}
