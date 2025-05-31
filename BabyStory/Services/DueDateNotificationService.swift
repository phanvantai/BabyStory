//
//  DueDateNotificationService.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation
import UserNotifications

/// Service responsible for managing due date reminder notifications for pregnancy profiles
class DueDateNotificationService {
    
    // MARK: - Properties
    private let storageManager: StorageManager
    private let permissionManager: NotificationPermissionManager
    private let userDefaultsKey = "DueDateNotificationHistory"
    
    // Debouncing mechanism to prevent duplicate scheduling
    private var lastScheduleTime: Date?
    private var lastScheduledProfileName: String?
    private let minimumScheduleInterval: TimeInterval = 1.0 // 1 second minimum between schedules
    
    // MARK: - Notification Identifiers
    enum NotificationIdentifier: String, CaseIterable {
        case threeDaysBefore = "due_date_3_days_before"
        case onDueDate = "due_date_on_date"
        case twoDaysAfter = "due_date_2_days_after"
        
        var title: String {
            switch self {
            case .threeDaysBefore:
                return "due_date_notification_title_three_days_before".localized
            case .onDueDate:
                return "due_date_notification_title_on_due_date".localized
            case .twoDaysAfter:
                return "due_date_notification_title_two_days_after".localized
            }
        }
        
        func body(for babyName: String) -> String {
            switch self {
            case .threeDaysBefore:
                return String(format: "due_date_notification_body_three_days_before".localized, babyName)
            case .onDueDate:
                return String(format: "due_date_notification_body_on_due_date".localized, babyName)
            case .twoDaysAfter:
                return String(format: "due_date_notification_body_two_days_after".localized, babyName)
            }
        }
    }
    
    // MARK: - Initialization
    init(storageManager: StorageManager = StorageManager.shared, permissionManager: NotificationPermissionManager = NotificationPermissionManager.shared) {
        self.storageManager = storageManager
        self.permissionManager = permissionManager
    }
    
    // MARK: - Public Methods
    
    /// Checks permission status and schedules due date notifications if authorized
    /// - Returns: true if notifications were scheduled or permission is granted, false if permission is needed
    func setupDueDateNotifications() async -> Bool {
        // Update permission status first
        await permissionManager.updatePermissionStatus()
        
        // Check current permission status
        switch permissionManager.permissionStatus {
        case .authorized, .provisional:
            // Permission already granted, schedule notifications
            await scheduleNotificationsForCurrentProfile()
            Logger.info("Due date notifications setup completed with existing permission", category: .notification)
            return true
            
        case .notDetermined:
            // Permission not determined - caller should show explanation first
            Logger.info("Notification permission not determined, user should be prompted", category: .notification)
            return false
            
        case .denied:
            // Permission explicitly denied
            Logger.info("Notification permission denied, cannot schedule notifications", category: .notification)
            return false
            
        case .unknown:
            // Unknown status, try to update again
            Logger.warning("Unknown notification permission status", category: .notification)
            return false
        }
    }
    
    /// Requests notification permission using the graceful permission manager
    /// This should only be called after user has seen an explanation
    func requestNotificationPermission() async -> Bool {
        let status = await permissionManager.requestPermission()
        
        if status.canSendNotifications {
            // Permission granted, schedule notifications only if not recently scheduled
            let now = Date()
            let shouldSchedule = lastScheduleTime == nil || 
                               (now.timeIntervalSince(lastScheduleTime!) > minimumScheduleInterval)
            
            if shouldSchedule {
                await scheduleNotificationsForCurrentProfile()
                Logger.info("Permission granted, due date notifications scheduled", category: .notification)
            } else {
                Logger.info("Permission granted, but notifications were recently scheduled - skipping duplicate scheduling", category: .notification)
            }
            return true
        } else {
            Logger.info("Permission denied, cannot schedule due date notifications", category: .notification)
            return false
        }
    }
    
    /// Checks if we should show permission explanation to the user
    func shouldShowPermissionExplanation() -> Bool {
        return permissionManager.shouldShowPermissionExplanation(for: .pregnancyReminders)
    }
    
    /// Schedules due date notifications for the current profile if it's a pregnancy profile
    func scheduleNotificationsForCurrentProfile() async {
        // Debouncing: Check if we've scheduled recently for the same profile
        let now = Date()
        
        do {
            guard let profile = try storageManager.loadProfile(),
                  profile.isPregnancy,
                  let dueDate = profile.dueDate else {
                Logger.debug("No pregnancy profile with due date found, skipping notification scheduling", category: .notification)
                return
            }
            
            // Check if we've scheduled recently for this same profile
            if let lastTime = lastScheduleTime, 
               let lastProfileName = lastScheduledProfileName,
               now.timeIntervalSince(lastTime) < minimumScheduleInterval && 
               lastProfileName == profile.name {
                Logger.debug("Skipping notification scheduling due to debouncing (last scheduled for \(lastProfileName) \(now.timeIntervalSince(lastTime)) seconds ago)", category: .notification)
                return
            }
            
            Logger.info("Scheduling due date notifications for pregnancy profile: \(profile.name)", category: .notification)
            
            // Update the last schedule time and profile before scheduling
            lastScheduleTime = now
            lastScheduledProfileName = profile.name
            
            await scheduleNotifications(for: profile, dueDate: dueDate)
            
        } catch {
            Logger.error("Failed to schedule notifications for current profile: \(error)", category: .notification)
        }
    }
    
    /// Cancels all due date notifications
    func cancelAllDueDateNotifications() {
        let identifiers = NotificationIdentifier.allCases.map { $0.rawValue }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        
        Logger.info("Cancelled all due date notifications", category: .notification)
    }
    
    /// Async version of cancelAllDueDateNotifications to ensure proper completion
    private func cancelAllDueDateNotificationsAsync() async {
        let identifiers = NotificationIdentifier.allCases.map { $0.rawValue }
        
        // Get current pending notifications to log what we're removing
        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let dueDateRequests = pendingRequests.filter { identifiers.contains($0.identifier) }
        
        if !dueDateRequests.isEmpty {
            Logger.debug("Found \(dueDateRequests.count) existing due date notifications to cancel", category: .notification)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            Logger.info("Cancelled \(dueDateRequests.count) due date notifications", category: .notification)
        } else {
            Logger.debug("No existing due date notifications found to cancel", category: .notification)
        }
    }
    
    /// Handles when user updates their profile manually (cancels future notifications)
    func handleProfileUpdate() {
        do {
            guard let profile = try storageManager.loadProfile() else { return }
            
            // If no longer pregnancy, cancel all notifications
            if !profile.isPregnancy {
                cancelAllDueDateNotifications()
                clearNotificationHistory()
                Logger.info("Profile no longer pregnancy, cancelled all due date notifications", category: .notification)
            }
            
        } catch {
            Logger.error("Failed to handle profile update for notifications: \(error)", category: .notification)
        }
    }
    
    // MARK: - Private Methods
    
    /// Schedules all three types of due date notifications
    private func scheduleNotifications(for profile: UserProfile, dueDate: Date) async {
        let calendar = Calendar.current
        let now = Date()
        
        // Clear existing notifications first
        Logger.info("Clearing existing due date notifications before scheduling new ones", category: .notification)
        await cancelAllDueDateNotificationsAsync()
        
        // Get notification history to avoid duplicate notifications
        let history = getNotificationHistory()
        let profileId = profile.name // Using name as simple identifier
        
        // Schedule 3 days before notification
        if let threeDaysBeforeDate = calendar.date(byAdding: .day, value: -3, to: dueDate),
           threeDaysBeforeDate > now,
           !history.hasSentNotification(for: profileId, type: .threeDaysBefore) {
            Logger.debug("Scheduling 3-days-before notification for \(threeDaysBeforeDate)", category: .notification)
            await scheduleNotification(
                identifier: NotificationIdentifier.threeDaysBefore,
                for: profile,
                at: threeDaysBeforeDate
            )
        }
        
        // Schedule on due date notification
        if dueDate > now,
           !history.hasSentNotification(for: profileId, type: .onDueDate) {
            Logger.debug("Scheduling on-due-date notification for \(dueDate)", category: .notification)
            await scheduleNotification(
                identifier: NotificationIdentifier.onDueDate,
                for: profile,
                at: dueDate
            )
        }
        
        // Schedule 2 days after notification
        if let twoDaysAfterDate = calendar.date(byAdding: .day, value: 2, to: dueDate),
           twoDaysAfterDate > now,
           !history.hasSentNotification(for: profileId, type: .twoDaysAfter) {
            Logger.debug("Scheduling 2-days-after notification for \(twoDaysAfterDate)", category: .notification)
            await scheduleNotification(
                identifier: NotificationIdentifier.twoDaysAfter,
                for: profile,
                at: twoDaysAfterDate
            )
        }
    }
    
    /// Schedules a single notification
    private func scheduleNotification(
        identifier: NotificationIdentifier,
        for profile: UserProfile,
        at date: Date
    ) async {
        Logger.debug("Starting to schedule notification: \(identifier.rawValue)", category: .notification)
        
        let content = UNMutableNotificationContent()
        content.title = identifier.title
        content.body = identifier.body(for: profile.name)
        content.sound = .default
        content.badge = 1
        
        // Add action buttons
        content.categoryIdentifier = "DUE_DATE_REMINDER"
        
        // Create date trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: identifier.rawValue,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            Logger.info("Scheduled due date notification: \(identifier.rawValue) for \(date)", category: .notification)
        } catch {
            Logger.error("Failed to schedule notification \(identifier.rawValue): \(error)", category: .notification)
        }
    }
    
    /// Marks a notification as sent in the history
    func markNotificationAsSent(for profile: UserProfile, type: NotificationIdentifier) {
        var history = getNotificationHistory()
        history.recordSentNotification(for: profile.name, type: type, date: Date())
        saveNotificationHistory(history)
        
        Logger.info("Marked notification as sent: \(type.rawValue) for \(profile.name)", category: .notification)
    }
    
    // MARK: - Notification History Management
    
    private func getNotificationHistory() -> NotificationHistory {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let history = try? JSONDecoder().decode(NotificationHistory.self, from: data) else {
            return NotificationHistory()
        }
        return history
    }
    
    private func saveNotificationHistory(_ history: NotificationHistory) {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func clearNotificationHistory() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        Logger.info("Cleared notification history", category: .notification)
    }
}

// MARK: - Supporting Models

/// Tracks notification history to avoid duplicate notifications
private struct NotificationHistory: Codable {
    private var sentNotifications: [String: [String: Date]] = [:]
    
    mutating func recordSentNotification(for profileId: String, type: DueDateNotificationService.NotificationIdentifier, date: Date) {
        if sentNotifications[profileId] == nil {
            sentNotifications[profileId] = [:]
        }
        sentNotifications[profileId]?[type.rawValue] = date
    }
    
    func hasSentNotification(for profileId: String, type: DueDateNotificationService.NotificationIdentifier) -> Bool {
        return sentNotifications[profileId]?[type.rawValue] != nil
    }
    
    func getLastSentDate(for profileId: String, type: DueDateNotificationService.NotificationIdentifier) -> Date? {
        return sentNotifications[profileId]?[type.rawValue]
    }
}
