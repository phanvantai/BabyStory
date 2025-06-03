//
//  MockDueDateNotificationService.swift
//  SoftDreamsTests
//
//  Created by Tests on 3/6/25.
//

import Foundation
@testable import SoftDreams

// MARK: - Mock Due Date Notification Service for Testing
class MockDueDateNotificationService: DueDateNotificationService, @unchecked Sendable {
  
  // MARK: - Initialization
   init(userProfileService: UserProfileServiceProtocol = MockUserProfileService(), 
                permissionManager: NotificationPermissionManager = NotificationPermissionManager.shared) {
    super.init(userProfileService: userProfileService, permissionManager: permissionManager)
  }
  
  // MARK: - Test Properties
  var setupDueDateNotificationsCalled = false
  var scheduleNotificationsForCurrentProfileCalled = false
  var handleProfileUpdateCalled = false
  var cancelAllDueDateNotificationsCalled = false
  var requestNotificationPermissionCalled = false
  var shouldShowPermissionExplanationCalled = false
  
  var setupDueDateNotificationsResult = true
  var requestNotificationPermissionResult = true
  var shouldShowPermissionExplanationResult = false
  
  // MARK: - Mock Methods
  
  override func setupDueDateNotifications() async -> Bool {
    setupDueDateNotificationsCalled = true
    return setupDueDateNotificationsResult
  }
  
  override func scheduleNotificationsForCurrentProfile() async {
    scheduleNotificationsForCurrentProfileCalled = true
  }
  
  override func handleProfileUpdate() {
    handleProfileUpdateCalled = true
  }
  
  override func cancelAllDueDateNotifications() {
    cancelAllDueDateNotificationsCalled = true
  }
  
  override func requestNotificationPermission() async -> Bool {
    requestNotificationPermissionCalled = true
    return requestNotificationPermissionResult
  }
  
  override func shouldShowPermissionExplanation() -> Bool {
    shouldShowPermissionExplanationCalled = true
    return shouldShowPermissionExplanationResult
  }
  
  // MARK: - Test Helper Methods
  
  func reset() {
    setupDueDateNotificationsCalled = false
    scheduleNotificationsForCurrentProfileCalled = false
    handleProfileUpdateCalled = false
    cancelAllDueDateNotificationsCalled = false
    requestNotificationPermissionCalled = false
    shouldShowPermissionExplanationCalled = false
    
    setupDueDateNotificationsResult = true
    requestNotificationPermissionResult = true
    shouldShowPermissionExplanationResult = false
  }
}
