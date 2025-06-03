//
//  AutoProfileUpdateServiceProtocol.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation

/// Protocol for auto profile update service that handles automatic updates of user profiles
/// based on age progression and other criteria
protocol AutoProfileUpdateServiceProtocol {
    
    /// Performs automatic profile updates and returns update results
    /// - Parameter profile: Optional user profile. If provided, avoids loading the profile again from storage
    /// - Returns: AutoUpdateResult containing information about what was updated
    func performAutoUpdate(profile: UserProfile?) async -> AutoUpdateResult
    
    /// Updates profile if needed - simplified interface for basic auto-update functionality
    func updateProfileIfNeeded() async
    
    /// Sets up due date notifications for the current profile
    /// Only schedules if permission is already granted, doesn't request permission
    func setupDueDateNotifications() async
    
    /// Checks if profile needs auto-updating without performing the update
    /// - Parameter profile: Optional user profile. If provided, avoids loading the profile again from storage
    /// - Returns: Bool indicating if auto-update is needed
    func needsAutoUpdate(profile: UserProfile?) -> Bool
}