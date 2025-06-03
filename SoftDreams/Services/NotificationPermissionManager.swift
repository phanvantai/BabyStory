//
//  NotificationPermissionManager.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation
import UserNotifications
import SwiftUI

/// Manages notification permissions with graceful user experience
class NotificationPermissionManager: ObservableObject {
    
    // MARK: - Properties
    @Published var permissionStatus: NotificationPermissionStatus = .unknown
    @Published var showPermissionSheet = false
    
    // MARK: - Permission Status
    enum NotificationPermissionStatus {
        case unknown
        case notDetermined
        case denied
        case authorized
        case provisional
        
        var canSendNotifications: Bool {
            switch self {
            case .authorized, .provisional:
                return true
            case .unknown, .notDetermined, .denied:
                return false
            }
        }
        
        var needsPermissionRequest: Bool {
            return self == .notDetermined
        }
        
        var isExplicitlyDenied: Bool {
            return self == .denied
        }
    }
    
    // MARK: - Singleton
    static let shared = NotificationPermissionManager()
    private init() {
        Task {
            await updatePermissionStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Updates the current permission status
    @MainActor
    func updatePermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            permissionStatus = .notDetermined
        case .denied:
            permissionStatus = .denied
        case .authorized:
            permissionStatus = .authorized
        case .provisional:
            permissionStatus = .provisional
        case .ephemeral:
            permissionStatus = .provisional
        @unknown default:
            permissionStatus = .unknown
        }
        
        Logger.info("Notification permission status updated: \(permissionStatus)", category: .notification)
    }
    
    /// Checks if we should show the permission explanation to the user
    func shouldShowPermissionExplanation(for context: PermissionContext) -> Bool {
        switch permissionStatus {
        case .notDetermined:
            return true
        case .denied:
            return context.showForDenied
        case .authorized, .provisional:
            return false
        case .unknown:
            return true
        }
    }
    
    /// Shows the permission explanation sheet
    @MainActor
    func showPermissionExplanation() {
        showPermissionSheet = true
    }
    
    /// Requests notification permission with graceful handling
    func requestPermission() async -> NotificationPermissionStatus {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await updatePermissionStatus()
            
            if granted {
                Logger.info("Notification permission granted", category: .notification)
            } else {
                Logger.info("Notification permission denied by user", category: .notification)
            }
            
            return permissionStatus
            
        } catch {
            Logger.error("Failed to request notification permission: \(error)", category: .notification)
            await updatePermissionStatus()
            return permissionStatus
        }
    }
    
    /// Opens the app's notification settings
    func openNotificationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            Logger.error("Could not create settings URL", category: .notification)
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                Logger.info("Opened notification settings: \(success)", category: .notification)
            }
        }
    }
}

// MARK: - Supporting Types

/// Context for when permission is being requested
struct PermissionContext: Equatable {
    let reason: String
    let benefits: [String]
    let showForDenied: Bool
    
    static let pregnancyReminders = PermissionContext(
        reason: "permission_context_pregnancy_reason".localized,
        benefits: [
            "permission_benefit_due_date_reminders".localized,
            "permission_benefit_profile_update_suggestions".localized,
            "permission_benefit_important_milestones".localized
        ],
        showForDenied: true
    )
    
    static let storyTime = PermissionContext(
        reason: "permission_context_story_time_reason".localized,
        benefits: [
            "permission_benefit_daily_story_reminders".localized,
            "permission_benefit_reading_routine_notifications".localized,
            "permission_benefit_new_story_alerts".localized
        ],
        showForDenied: true
    )
    
    static let general = PermissionContext(
        reason: "permission_context_general_reason".localized,
        benefits: [
            "permission_benefit_story_time_reminders".localized,
            "permission_benefit_profile_updates".localized,
            "permission_benefit_milestone_celebrations".localized
        ],
        showForDenied: true
    )
}
