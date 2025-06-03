//
//  StoryTimeNotificationService.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
import UserNotifications

/// Service responsible for managing story time reminder notifications
class StoryTimeNotificationService: StoryTimeNotificationServiceProtocol {
  
  // MARK: - Properties
  private let permissionManager: any NotificationPermissionManagerProtocol
  private let notificationReminderTimeInterval: TimeInterval = 600 // 10 minutes in seconds
  private let minimumFutureBuffer: TimeInterval = 300 // 5 minutes minimum buffer for scheduling
  
  // Notification identifiers
  enum NotificationIdentifier: String {
    case storyTimeReminder = "story_time_reminder"
  }
  
  // MARK: - Initialization
  init(permissionManager: any NotificationPermissionManagerProtocol = NotificationPermissionManager.shared) {
    self.permissionManager = permissionManager
  }
  
  // MARK: - Public Methods
  
  /// Schedules a notification that will trigger 10 minutes before the provided story time
  /// - Parameters:
  ///   - storyTime: The time when story time is scheduled
  ///   - babyName: The name of the baby to personalize the notification
  /// - Returns: Boolean indicating whether the notification was successfully scheduled
  func scheduleStoryTimeReminder(for storyTime: Date, babyName: String) async -> Bool {
    // Update permission status first
    await permissionManager.updatePermissionStatus()
    
    // Check current permission status
    guard permissionManager.permissionStatus.canSendNotifications else {
      Logger.info("Cannot schedule story time notifications, permission not granted", category: .notification)
      return false
    }
    
    // Cancel any existing notifications first
    await cancelStoryTimeReminders()
    
    // Current time for comparison
    let now = Date()
    let calendar = Calendar.current
    
    // Extract hour and minute from the provided story time
    let storyTimeComponents = calendar.dateComponents([.hour, .minute], from: storyTime)
    
    // Create a date for today with the story time's hour and minute
    let todayWithStoryTime = calendar.date(bySettingHour: storyTimeComponents.hour ?? 0, 
                                           minute: storyTimeComponents.minute ?? 0, 
                                           second: 0, 
                                           of: now) ?? now
    
    // Calculate notification time (10 minutes before story time)
    let todayNotificationTime = todayWithStoryTime.addingTimeInterval(-notificationReminderTimeInterval)
    
    // Calculate the minimum valid notification time (now + buffer)
    let minimumValidTime = now.addingTimeInterval(minimumFutureBuffer)
    
    // Check if notification would be too soon or in the past
    if todayNotificationTime < minimumValidTime {
      Logger.info("Story time notification would be too soon (less than 5 minutes from now), scheduling for tomorrow", category: .notification)
      
      // Create tomorrow's date with the same hour and minute
      guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
        Logger.error("Failed to calculate tomorrow's date", category: .notification)
        return false
      }
      
      // Set the hour and minute from the original story time to tomorrow
      guard let tomorrowStoryTime = calendar.date(bySettingHour: storyTimeComponents.hour ?? 0, 
                                                  minute: storyTimeComponents.minute ?? 0, 
                                                  second: 0, 
                                                  of: tomorrow) else {
        Logger.error("Failed to set time for tomorrow's story time", category: .notification)
        return false
      }
      
      let tomorrowNotificationTime = tomorrowStoryTime.addingTimeInterval(-notificationReminderTimeInterval)
      Logger.info("Rescheduled for tomorrow at \(tomorrowStoryTime.formatted(date: .omitted, time: .standard))", category: .notification)
      
      return await scheduleNotification(for: tomorrowStoryTime, at: tomorrowNotificationTime, babyName: babyName)
    }
    
    // Schedule notification for today
    Logger.info("Scheduling story time notification for today at \(todayNotificationTime.formatted(date: .numeric, time: .standard))", category: .notification)
    return await scheduleNotification(for: todayWithStoryTime, at: todayNotificationTime, babyName: babyName)
  }
  
  /// Private helper method to schedule the actual notification
  /// - Parameters:
  ///   - storyTime: The actual story time (for logging)
  ///   - notificationTime: The time when notification should be triggered
  ///   - babyName: The name of the baby to personalize the notification
  /// - Returns: Boolean indicating success
  private func scheduleNotification(for storyTime: Date, at notificationTime: Date, babyName: String) async -> Bool {
    do {
      // Create notification content
      let content = UNMutableNotificationContent()
      content.title = "story_time_notification_title".localized
      
      // Personalize the notification body with the baby's name
      if !babyName.isEmpty {
        content.body = String(format: "story_time_notification_body_personalized".localized, babyName)
      } else {
        content.body = "story_time_notification_body".localized
      }
      
      content.sound = UNNotificationSound.default
      content.categoryIdentifier = "STORY_TIME"
      
      // Extract date and time components for the trigger
      let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
      
      // Create trigger with all date components to ensure correct date
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      
      // Create request
      let request = UNNotificationRequest(
        identifier: NotificationIdentifier.storyTimeReminder.rawValue,
        content: content,
        trigger: trigger
      )
      
      // Schedule notification
      try await UNUserNotificationCenter.current().add(request)
      
      Logger.info("Successfully scheduled story time reminder for \(storyTime.formatted()) (notification at \(notificationTime.formatted()))", category: .notification)
      return true
    } catch {
      Logger.error("Failed to schedule story time reminder: \(error)", category: .notification)
      return false
    }
  }
  
  /// Cancels all pending story time reminder notifications
  func cancelStoryTimeReminders() async {
    let identifiers = [NotificationIdentifier.storyTimeReminder.rawValue]
    
    // Get current pending notifications to log what we're removing
    let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
    let storyTimeRequests = pendingRequests.filter { identifiers.contains($0.identifier) }
    
    if !storyTimeRequests.isEmpty {
      Logger.debug("Found \(storyTimeRequests.count) existing story time reminders to cancel", category: .notification)
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
      Logger.info("Cancelled \(storyTimeRequests.count) story time reminder notifications", category: .notification)
    } else {
      Logger.debug("No existing story time reminders found to cancel", category: .notification)
    }
  }
  
  /// Requests notification permission using the graceful permission manager
  /// This should only be called after user has seen an explanation
  func requestNotificationPermission() async -> Bool {
    let status = await permissionManager.requestPermission()
    
    if status.canSendNotifications {
      Logger.info("Permission granted for story time notifications", category: .notification)
      return true
    } else {
      Logger.info("Permission denied for story time notifications", category: .notification)
      return false
    }
  }
  
  /// Checks if we should show permission explanation to the user
  func shouldShowPermissionExplanation() -> Bool {
    return permissionManager.shouldShowPermissionExplanation(for: .storyTime)
  }
}
