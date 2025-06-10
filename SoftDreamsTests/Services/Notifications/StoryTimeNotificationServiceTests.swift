//
//  StoryTimeNotificationServiceTests.swift
//  SoftDreamsTests
//
//  Created by GitHub Copilot on 10/6/25.
//

import Testing
import UserNotifications
@testable import SoftDreams

@Suite("StoryTimeNotificationService Tests")
struct StoryTimeNotificationServiceTests {
    
    @Test("Notification scheduling with daily repeats")
    func testScheduleStoryTimeReminderWithDailyRepeats() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .authorized
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        
        // Create a story time for testing (2 hours from now)
        let calendar = Calendar.current
        let now = Date()
        let storyTime = calendar.date(byAdding: .hour, value: 2, to: now)!
        let babyName = "TestBaby"
        
        // When
        let result = await service.scheduleStoryTimeReminder(for: storyTime, babyName: babyName)
        
        // Then
        #expect(result == true, "Notification should be successfully scheduled")
        
        // Verify that the notification was actually scheduled
        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let storyTimeRequests = pendingRequests.filter { $0.identifier == "story_time_reminder" }
        
        #expect(storyTimeRequests.count == 1, "Should have exactly one story time notification scheduled")
        
        if let request = storyTimeRequests.first,
           let trigger = request.trigger as? UNCalendarNotificationTrigger {
            #expect(trigger.repeats == true, "Notification should be set to repeat daily")
            
            // Verify the trigger only contains hour and minute (not date components)
            let components = trigger.dateComponents
            #expect(components.hour != nil, "Hour should be specified")
            #expect(components.minute != nil, "Minute should be specified")
            #expect(components.year == nil, "Year should not be specified for daily repeats")
            #expect(components.month == nil, "Month should not be specified for daily repeats")
            #expect(components.day == nil, "Day should not be specified for daily repeats")
        }
    }
    
    @Test("Notification scheduling without permission")
    func testScheduleStoryTimeReminderWithoutPermission() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .denied
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        
        let storyTime = Date().addingTimeInterval(3600) // 1 hour from now
        let babyName = "TestBaby"
        
        // When
        let result = await service.scheduleStoryTimeReminder(for: storyTime, babyName: babyName)
        
        // Then
        #expect(result == false, "Notification should fail without permission")
    }
    
    @Test("Canceling story time reminders")
    func testCancelStoryTimeReminders() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .authorized
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        
        // Schedule a notification first
        let storyTime = Date().addingTimeInterval(3600) // 1 hour from now
        let babyName = "TestBaby"
        _ = await service.scheduleStoryTimeReminder(for: storyTime, babyName: babyName)
        
        // Verify it was scheduled
        let pendingBefore = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let storyTimeBefore = pendingBefore.filter { $0.identifier == "story_time_reminder" }
        #expect(storyTimeBefore.count == 1, "Should have one notification before canceling")
        
        // When
        await service.cancelStoryTimeReminders()
        
        // Then
        let pendingAfter = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let storyTimeAfter = pendingAfter.filter { $0.identifier == "story_time_reminder" }
        #expect(storyTimeAfter.count == 0, "Should have no story time notifications after canceling")
    }
    
    @Test("Checking if story time reminders are scheduled")
    func testHasScheduledStoryTimeReminders() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .authorized
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        
        // When - check before scheduling any notifications
        let hasScheduledBefore = await service.hasScheduledStoryTimeReminders()
        
        // Then
        #expect(hasScheduledBefore == false, "Should not have scheduled notifications initially")
        
        // When - schedule a notification
        let storyTime = Date().addingTimeInterval(3600) // 1 hour from now
        let babyName = "TestBaby"
        _ = await service.scheduleStoryTimeReminder(for: storyTime, babyName: babyName)
        
        // Then - check after scheduling
        let hasScheduledAfter = await service.hasScheduledStoryTimeReminders()
        #expect(hasScheduledAfter == true, "Should have scheduled notifications after scheduling")
        
        // When - cancel notifications
        await service.cancelStoryTimeReminders()
        
        // Then - check after canceling
        let hasScheduledAfterCancel = await service.hasScheduledStoryTimeReminders()
        #expect(hasScheduledAfterCancel == false, "Should not have scheduled notifications after canceling")
    }
}

// MARK: - Mock Classes

class MockNotificationPermissionManager: NotificationPermissionManagerProtocol {
    var permissionStatus: NotificationPermissionStatus = .notDetermined
    var showPermissionSheet: Bool = false
    
    func updatePermissionStatus() async {
        // Mock implementation - status is controlled by test
    }
    
    func shouldShowPermissionExplanation(for context: PermissionContext) -> Bool {
        return permissionStatus == .notDetermined
    }
    
    func showPermissionExplanation() {
        // Mock implementation
        showPermissionSheet = true
    }
    
    func requestPermission() async -> NotificationPermissionStatus {
        return permissionStatus
    }
    
    func openNotificationSettings() {
        // Mock implementation
    }
}
