//
//  BabyStoryApp.swift
//  BabyStory
//
//  Created by Tai Phan Van on 28/5/25.
//

import SwiftUI
import UserNotifications

@main
struct BabyStoryApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var notificationDelegate = NotificationDelegate()
  @AppStorage("AppLanguage") var language: String = "en"
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
                .withCustomNavigationBarAppearance() // Apply custom navigation bar appearance
                .animation(.easeInOut(duration: 0.3), value: themeManager.preferredColorScheme)
                .onAppear {
                    setupNotifications()
                }
                .environment(\.locale, .init(identifier: language))
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        // Set up notification categories with actions
        setupNotificationCategories()
        
        // Setup due date notifications only for existing users (not during onboarding)
        Task {
            // Only setup notifications if onboarding has been completed
            if StorageManager.shared.hasCompletedOnboarding {
                Logger.info("Setting up due date notifications for existing user", category: .notification)
                let autoUpdateService = AutoProfileUpdateService()
                await autoUpdateService.setupDueDateNotifications()
            } else {
                Logger.info("Skipping notification setup - onboarding not completed", category: .notification)
            }
        }
    }
    
    private func setupNotificationCategories() {
        let updateAction = UNNotificationAction(
            identifier: "UPDATE_PROFILE",
            title: "Update Profile",
            options: [.foreground]
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Later",
            options: []
        )
        
        let dueDateCategory = UNNotificationCategory(
            identifier: "DUE_DATE_REMINDER",
            actions: [updateAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([dueDateCategory])
    }
}

/// Handles notification responses and presentation
class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "UPDATE_PROFILE":
            // Handle profile update action - could open the app to edit profile
            Logger.info("User selected update profile from notification", category: .notification)
            // The app will open and user can navigate to profile edit
            
        case "REMIND_LATER":
            // Schedule a reminder for tomorrow
            Logger.info("User selected remind later from notification", category: .notification)
            scheduleRemindLaterNotification()
            
        default:
            // Default action (tap notification)
            Logger.info("User tapped notification", category: .notification)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    private func scheduleRemindLaterNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Profile Update Reminder 👶"
        content.body = "Don't forget to update your baby's profile for personalized stories!"
        content.sound = .default
        content.categoryIdentifier = "DUE_DATE_REMINDER"
        
        // Schedule for tomorrow at the same time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "remind_later_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.error("Failed to schedule remind later notification: \(error)", category: .notification)
            } else {
                Logger.info("Scheduled remind later notification for tomorrow", category: .notification)
            }
        }
    }
}
