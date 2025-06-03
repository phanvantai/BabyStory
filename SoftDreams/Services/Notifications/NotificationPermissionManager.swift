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
class NotificationPermissionManager: ObservableObject, @preconcurrency NotificationPermissionManagerProtocol {
  
  // MARK: - Properties
  @Published var permissionStatus: NotificationPermissionStatus = .unknown
  @Published var showPermissionSheet = false
  
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
