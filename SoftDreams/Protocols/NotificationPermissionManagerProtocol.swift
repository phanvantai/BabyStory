//
//  NotificationPermissionManagerProtocol.swift
//  SoftDreams
//
//  Created by Tests on 3/6/25.
//

import Foundation
import SwiftUI

/// Protocol for managing notification permissions
protocol NotificationPermissionManagerProtocol: ObservableObject {
    var permissionStatus: NotificationPermissionStatus { get set }
    var showPermissionSheet: Bool { get set }
    
    func updatePermissionStatus() async
    func shouldShowPermissionExplanation(for context: PermissionContext) -> Bool
    func showPermissionExplanation()
    func requestPermission() async -> NotificationPermissionStatus
    func openNotificationSettings()
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
