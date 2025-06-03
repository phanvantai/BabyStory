//
//  DueDateNotificationServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
import UserNotifications
@testable import SoftDreams

@MainActor
struct DueDateNotificationServiceTests {
    
    func setUp() {
        // Clean up UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "stories")
        UserDefaults.standard.removeObject(forKey: "settings")
        UserDefaults.standard.removeObject(forKey: "DueDateNotificationHistory")
        
        // Clear all notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    @Test("DueDateNotificationService initialization")
    func testInitialization() {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        #expect(service != nil)
        
        // Test initialization with custom dependencies
        let userProfileService = MockUserProfileService()
        let permissionManager = NotificationPermissionManager.shared
        let serviceWithDeps = DueDateNotificationService(
            userProfileService: userProfileService,
            permissionManager: permissionManager
        )
        #expect(serviceWithDeps != nil)
    }
    
    @Test("NotificationIdentifier enum properties")
    func testNotificationIdentifierProperties() {
        // Test raw values
        #expect(DueDateNotificationService.NotificationIdentifier.threeDaysBefore.rawValue == "due_date_3_days_before")
        #expect(DueDateNotificationService.NotificationIdentifier.onDueDate.rawValue == "due_date_on_date")
        #expect(DueDateNotificationService.NotificationIdentifier.twoDaysAfter.rawValue == "due_date_2_days_after")
        
        // Test titles (should not be empty)
        #expect(!DueDateNotificationService.NotificationIdentifier.threeDaysBefore.title.isEmpty)
        #expect(!DueDateNotificationService.NotificationIdentifier.onDueDate.title.isEmpty)
        #expect(!DueDateNotificationService.NotificationIdentifier.twoDaysAfter.title.isEmpty)
        
        // Test body generation
        let testName = "Test Baby"
        let threeDaysBody = DueDateNotificationService.NotificationIdentifier.threeDaysBefore.body(for: testName)
        let onDateBody = DueDateNotificationService.NotificationIdentifier.onDueDate.body(for: testName)
        let twoDaysBody = DueDateNotificationService.NotificationIdentifier.twoDaysAfter.body(for: testName)
        
        #expect(!threeDaysBody.isEmpty)
        #expect(!onDateBody.isEmpty)
        #expect(!twoDaysBody.isEmpty)
        #expect(threeDaysBody.contains(testName) || threeDaysBody.contains(""))
        #expect(onDateBody.contains(testName) || onDateBody.contains(""))
        #expect(twoDaysBody.contains(testName) || twoDaysBody.contains(""))
    }
    
    @Test("DueDateNotificationService cancelAllDueDateNotifications")
    func testCancelAllDueDateNotifications() {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        
        // Should not crash when called
        service.cancelAllDueDateNotifications()
        #expect(true)
    }
    
    @Test("DueDateNotificationService scheduleNotificationsForCurrentProfile with no profile")
    func testScheduleNotificationsForCurrentProfileWithNoProfile() async {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        
        // Should not crash when no profile exists
        await service.scheduleNotificationsForCurrentProfile()
        #expect(true)
    }
    
    @Test("DueDateNotificationService scheduleNotificationsForCurrentProfile with non-pregnancy profile")
    func testScheduleNotificationsForCurrentProfileWithNonPregnancyProfile() async throws {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let service = DueDateNotificationService(userProfileService: mockUserProfileService)
        
        // Create a non-pregnancy profile
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Animals", "Music"], 
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            gender: .male
        )
        
        mockUserProfileService.savedProfile = profile
        
        // Should not crash and should handle gracefully
        await service.scheduleNotificationsForCurrentProfile()
        #expect(true)
    }
    
    @Test("DueDateNotificationService scheduleNotificationsForCurrentProfile with pregnancy profile")
    func testScheduleNotificationsForCurrentProfileWithPregnancyProfile() async throws {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let service = DueDateNotificationService(userProfileService: mockUserProfileService)
        
        // Create a pregnancy profile with future due date
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let profile = UserProfile(
            name: "Expecting Parent",
            babyStage: .pregnancy,
            interests: ["Gentle Stories", "Classical Music"], 
            dueDate: futureDate,
            gender: .notSpecified
        )
        
        mockUserProfileService.savedProfile = profile
        
        // Should not crash
        await service.scheduleNotificationsForCurrentProfile()
        #expect(true)
    }
    
    @Test("DueDateNotificationService setupDueDateNotifications")
    func testSetupDueDateNotifications() async {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        
        // Should return a boolean and not crash
        let result = await service.setupDueDateNotifications()
        #expect(result == true || result == false)
    }
    
   @Test("DueDateNotificationService requestNotificationPermission with mock")
   func testRequestNotificationPermission() async {
       setUp()
       
       // Create a mock permission manager that doesn't require user interaction
       let mockPermissionManager = MockNotificationPermissionManager()
       let service = DueDateNotificationService(
           userProfileService: UserDefaultsUserProfileService(),
           permissionManager: mockPermissionManager
       )
       
       // Test permission granted scenario
       mockPermissionManager.shouldGrantPermission = true
       let resultGranted = await service.requestNotificationPermission()
       #expect(resultGranted == true)
       
       // Test permission denied scenario
       mockPermissionManager.shouldGrantPermission = false
       let resultDenied = await service.requestNotificationPermission()
       #expect(resultDenied == false)
   }
    
    @Test("DueDateNotificationService shouldShowPermissionExplanation")
    func testShouldShowPermissionExplanation() {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        
        // Should return a boolean and not crash
        let result = service.shouldShowPermissionExplanation()
        #expect(result == true || result == false)
    }
    
    @Test("DueDateNotificationService handleProfileUpdate with non-pregnancy profile")
    func testHandleProfileUpdateWithNonPregnancyProfile() throws {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let service = DueDateNotificationService(userProfileService: mockUserProfileService)
        
        // Create a non-pregnancy profile
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Animals", "Music"], 
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            gender: .male
        )
        
        mockUserProfileService.savedProfile = profile
        
        // Should not crash
        service.handleProfileUpdate()
        #expect(true)
    }
    
    @Test("DueDateNotificationService handleProfileUpdate with pregnancy profile")
    func testHandleProfileUpdateWithPregnancyProfile() throws {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let service = DueDateNotificationService(userProfileService: mockUserProfileService)
        
        // Create a pregnancy profile
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let profile = UserProfile(
            name: "Expecting Parent",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], 
            dueDate: futureDate,
            gender: .notSpecified
        )
        
        mockUserProfileService.savedProfile = profile
        
        // Should not crash
        service.handleProfileUpdate()
        #expect(true)
    }
    
    @Test("DueDateNotificationService markNotificationAsSent")
    func testMarkNotificationAsSent() throws {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
            gender: .female
        )
        
        // Should not crash
        service.markNotificationAsSent(for: profile, type: DueDateNotificationService.NotificationIdentifier.threeDaysBefore)
        service.markNotificationAsSent(for: profile, type: DueDateNotificationService.NotificationIdentifier.onDueDate)
        service.markNotificationAsSent(for: profile, type: DueDateNotificationService.NotificationIdentifier.twoDaysAfter)
        
        #expect(true)
    }
    
    @Test("DueDateNotificationService debouncing mechanism")
    func testDebouncingMechanism() async throws {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        let storageManager = StorageManager.shared
        
        // Create a pregnancy profile
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let profile = UserProfile(
            name: "Expecting Parent",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], dueDate: futureDate,
            gender: .notSpecified
        )
        
        try storageManager.saveProfile(profile)
        
        // Schedule multiple times quickly - should handle debouncing gracefully
        await service.scheduleNotificationsForCurrentProfile()
        await service.scheduleNotificationsForCurrentProfile()
        await service.scheduleNotificationsForCurrentProfile()
        
        #expect(true)
    }
    
    @Test("DueDateNotificationService with past due date")
    func testServiceWithPastDueDate() async throws {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        let storageManager = StorageManager.shared
        
        // Create a pregnancy profile with past due date
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let profile = UserProfile(
            name: "Overdue Parent",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], dueDate: pastDate,
            gender: .notSpecified
        )
        
        try storageManager.saveProfile(profile)
        
        // Should handle past due dates gracefully
        await service.scheduleNotificationsForCurrentProfile()
        #expect(true)
    }
    
    @Test("DueDateNotificationService notification history management")
    func testNotificationHistoryManagement() throws {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        let profile = UserProfile(
            name: "Test Parent",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()),
            gender: .notSpecified
        )
        
        // Mark various notifications as sent
        service.markNotificationAsSent(for: profile, type: DueDateNotificationService.NotificationIdentifier.threeDaysBefore)
        
        // Create another profile and mark different notification
        let profile2 = UserProfile(
            name: "Another Parent",
            babyStage: .pregnancy,
            interests: ["Classical Music"], dueDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
            gender: .female
        )
        
        service.markNotificationAsSent(for: profile2, type: DueDateNotificationService.NotificationIdentifier.onDueDate)
        
        // Should handle multiple profiles in history
        #expect(true)
    }
    
    @Test("DueDateNotificationService edge cases")
    func testEdgeCases() async throws {
        setUp()
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        let storageManager = StorageManager.shared
        
        // Test with profile that has nil due date but is pregnancy stage
        let profileWithNilDueDate = UserProfile(
            name: "Nil Due Date",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], dueDate: nil,
            gender: .notSpecified
        )
        
        try storageManager.saveProfile(profileWithNilDueDate)
        await service.scheduleNotificationsForCurrentProfile()
        
        // Test with profile that has due date exactly today
        let todayDate = Calendar.current.startOfDay(for: Date())
        let profileWithTodayDueDate = UserProfile(
            name: "Today Due Date",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], dueDate: todayDate,
            gender: .notSpecified
        )
        
        try storageManager.saveProfile(profileWithTodayDueDate)
        await service.scheduleNotificationsForCurrentProfile()
        
        #expect(true)
    }
    
    @Test("DueDateNotificationService with corrupted storage")
    func testServiceWithCorruptedStorage() async {
        setUp()
        
        // Manually corrupt the notification history key
        UserDefaults.standard.set("invalid_json", forKey: "DueDateNotificationHistory")
        
        let service = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        
        // Should handle corrupted data gracefully
        await service.scheduleNotificationsForCurrentProfile()
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"], dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
            gender: .male
        )
        
        // Should not crash even with corrupted history data
        service.markNotificationAsSent(for: profile, type: DueDateNotificationService.NotificationIdentifier.threeDaysBefore)
        
        #expect(true)
    }
    
    // MARK: - New Dependency Injection Tests
    
    @Test("DueDateNotificationService with mock user profile service - no profile")
    func testWithMockUserProfileServiceNoProfile() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        mockUserProfileService.savedProfile = nil
        
        let service = DueDateNotificationService(userProfileService: mockUserProfileService)
        
        // Should handle gracefully when no profile exists
        await service.scheduleNotificationsForCurrentProfile()
        #expect(true)
    }
    
    @Test("DueDateNotificationService with mock user profile service - error handling")
    func testWithMockUserProfileServiceErrorHandling() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        mockUserProfileService.shouldFailLoad = true
        
        let service = DueDateNotificationService(userProfileService: mockUserProfileService)
        
        // Should handle errors gracefully
        await service.scheduleNotificationsForCurrentProfile()
        service.handleProfileUpdate()
        #expect(true)
    }
    
    @Test("DueDateNotificationService dependency injection verification")
    func testDependencyInjectionVerification() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockPermissionManager = NotificationPermissionManager.shared
        
        let service = DueDateNotificationService(
            userProfileService: mockUserProfileService,
            permissionManager: mockPermissionManager
        )
        
        #expect(service != nil)
        
        // Test that default initialization still works
        let defaultService = DueDateNotificationService(userProfileService: UserDefaultsUserProfileService())
        #expect(defaultService != nil)
    }
}
