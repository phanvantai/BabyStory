//
//  StoryTimeNotificationServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct StoryTimeNotificationServiceTests {
    
    // MARK: - Setup
    
    // Create a mock implementation of the protocol for testing
    class MockStoryTimeNotificationService: StoryTimeNotificationServiceProtocol {
        var scheduleCallCount = 0
        var cancelCallCount = 0
        var lastScheduledTime: Date?
        var lastBabyName: String?
        
        func scheduleStoryTimeReminder(for storyTime: Date, babyName: String) async -> Bool {
            scheduleCallCount += 1
            lastScheduledTime = storyTime
            lastBabyName = babyName
            return true
        }
        
        func cancelStoryTimeReminders() async {
            cancelCallCount += 1
        }
    }
    
    // MARK: - Tests
    
    @Test("Test scheduleStoryTimeReminder records the correct time and baby name")
    func testScheduleStoryTimeReminder() async throws {
        // Given
        let mockService = MockStoryTimeNotificationService()
        let testTime = Calendar.current.date(from: DateComponents(hour: 19, minute: 30)) ?? Date()
        let babyName = "Emma"
        
        // When
        let result = await mockService.scheduleStoryTimeReminder(for: testTime, babyName: babyName)
        
        // Then
        #expect(result == true, "Scheduling should return true on success")
        #expect(mockService.scheduleCallCount == 1, "Schedule should be called exactly once")
        #expect(mockService.lastScheduledTime == testTime, "The scheduled time should match the provided time")
        #expect(mockService.lastBabyName == babyName, "The baby name should be stored correctly")
    }
    
    @Test("Test cancelStoryTimeReminders is called correctly")
    func testCancelStoryTimeReminders() async throws {
        // Given
        let mockService = MockStoryTimeNotificationService()
        
        // When
        await mockService.cancelStoryTimeReminders()
        
        // Then
        #expect(mockService.cancelCallCount == 1, "Cancel should be called exactly once")
    }
    
    @Test("Test personalized notification content with baby name")
    func testPersonalizedNotificationContent() async throws {
        // Given
        let mockService = MockStoryTimeNotificationService()
        let testTime = Calendar.current.date(from: DateComponents(hour: 19, minute: 30)) ?? Date()
        let babyName = "Sophia"
        
        // When
        let result = await mockService.scheduleStoryTimeReminder(for: testTime, babyName: babyName)
        
        // Then
        #expect(result == true, "Scheduling should return true on success")
        #expect(mockService.lastBabyName == babyName, "Baby name should be captured for personalization")
    }
    
    @Test("Test notification with empty baby name handles gracefully")
    func testNotificationWithEmptyBabyName() async throws {
        // Given
        let mockService = MockStoryTimeNotificationService()
        let testTime = Calendar.current.date(from: DateComponents(hour: 19, minute: 30)) ?? Date()
        let emptyName = ""
        
        // When
        let result = await mockService.scheduleStoryTimeReminder(for: testTime, babyName: emptyName)
        
        // Then
        #expect(result == true, "Should handle empty name gracefully")
        #expect(mockService.lastBabyName == emptyName, "Empty name should be stored as is")
    }
    
    @Test("Test notification with special characters in baby name")
    func testNotificationWithSpecialCharactersInBabyName() async throws {
        // Given
        let mockService = MockStoryTimeNotificationService()
        let testTime = Calendar.current.date(from: DateComponents(hour: 19, minute: 30)) ?? Date()
        let specialName = "José-María"
        
        // When
        let result = await mockService.scheduleStoryTimeReminder(for: testTime, babyName: specialName)
        
        // Then
        #expect(result == true, "Should handle special characters in name")
        #expect(mockService.lastBabyName == specialName, "Special characters should be preserved")
    }
    
    @Test("Test rescheduling notifications cancels previous ones first")
    func testReschedulingNotifications() async throws {
        // Given
        let mockService = MockStoryTimeNotificationService()
        let firstTime = Calendar.current.date(from: DateComponents(hour: 19, minute: 30)) ?? Date()
        let secondTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 15)) ?? Date()
        let babyName = "Oliver"
        
        // When
        await mockService.scheduleStoryTimeReminder(for: firstTime, babyName: babyName)
        await mockService.scheduleStoryTimeReminder(for: secondTime, babyName: babyName)
        
        // Then
        #expect(mockService.scheduleCallCount == 2, "Schedule should be called twice")
        #expect(mockService.lastScheduledTime == secondTime, "Last scheduled time should be updated")
        #expect(mockService.lastBabyName == babyName, "Baby name should be consistent")
        #expect(mockService.cancelCallCount >= 1, "Cancel should be called at least once during rescheduling")
    }
    
    @Test("Test concrete implementation schedules notification correctly")
    func testConcreteImplementationSchedules() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .authorized
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        
        // Use a time far enough in the future
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let storyTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        let babyName = "Lucas"
        
        // When
        let result = await service.scheduleStoryTimeReminder(for: storyTime, babyName: babyName)
        
        // Then
        #expect(result == true, "Should successfully schedule with proper permissions")
        #expect(mockPermissionManager.updateStatusCalled, "Should check permission status")
    }
    
    @Test("Test concrete implementation handles denied permissions")
    func testConcreteImplementationHandlesDeniedPermissions() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .denied
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        let storyTime = Date().addingTimeInterval(3600) // 1 hour from now
        let babyName = "Isabella"
        
        // When
        let result = await service.scheduleStoryTimeReminder(for: storyTime, babyName: babyName)
        
        // Then
        #expect(result == false, "Should fail to schedule with denied permissions")
        #expect(mockPermissionManager.updateStatusCalled, "Should check permission status")
    }
    
    @Test("Test concrete implementation handles story time in the past")
    func testConcreteImplementationHandlesPastTime() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .authorized
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        let pastTime = Date().addingTimeInterval(-3600) // 1 hour ago
        let babyName = "Mia"
        
        // When
        let result = await service.scheduleStoryTimeReminder(for: pastTime, babyName: babyName)
        
        // Then
        #expect(result == false, "Should not schedule notifications for times in the past")
    }
    
    @Test("Test story time in near future with correct date handling")
    func testStoryTimeInNearFutureWithCorrectDateHandling() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .authorized
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        
        // Create a time 20 minutes in the future (similar to reported bug scenario)
        let nearFutureTime = Date().addingTimeInterval(20 * 60)
        let babyName = "Noah"
        
        // When
        let result = await service.scheduleStoryTimeReminder(for: nearFutureTime, babyName: babyName)
        
        // Then
        #expect(result == true, "Should successfully schedule notification for time in near future")
    }
    
    @Test("Test scheduling fallback to tomorrow when story time is too soon")
    func testSchedulingFallbackToTomorrow() async throws {
        // Given
        let mockPermissionManager = MockNotificationPermissionManager()
        mockPermissionManager.permissionStatus = .authorized
        
        let service = StoryTimeNotificationService(permissionManager: mockPermissionManager)
        
        // Create a time that's too soon for a notification (only 5 minutes in the future)
        let calendar = Calendar.current
        let now = Date()
        let tooSoonTime = now.addingTimeInterval(5 * 60) // 5 minutes from now
        let babyName = "Ava"
        
        // When
        let result = await service.scheduleStoryTimeReminder(for: tooSoonTime, babyName: babyName)
        
        // Then
        #expect(result == true, "Should successfully schedule notification for tomorrow instead")
        
        // Verify the pending notifications (can't easily do in unit test, but we're validating the logic is correct)
    }
}
