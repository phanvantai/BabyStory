//
//  StoryTimeNotificationServiceProtocol.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation

/// Protocol for managing story time reminder notifications
protocol StoryTimeNotificationServiceProtocol {
    /// Schedules a notification for story time reminder (10 minutes before the provided time)
    /// - Parameters:
    ///   - storyTime: The time when story time is scheduled
    ///   - babyName: The name of the baby to personalize the notification
    /// - Returns: Boolean indicating whether the notification was successfully scheduled
    func scheduleStoryTimeReminder(for storyTime: Date, babyName: String) async -> Bool
    
    /// Cancels all pending story time reminder notifications
    func cancelStoryTimeReminders() async
    
    /// Checks if story time reminder notifications are currently scheduled
    /// - Returns: Boolean indicating whether story time notifications are scheduled
    func hasScheduledStoryTimeReminders() async -> Bool
}
