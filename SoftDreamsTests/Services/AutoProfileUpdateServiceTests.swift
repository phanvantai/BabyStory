//
//  AutoProfileUpdateServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct AutoProfileUpdateServiceTests {
    
    func setUp() {
        // Clean up UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "stories")
        UserDefaults.standard.removeObject(forKey: "settings")
    }
    
    @Test("AutoProfileUpdateService initialization with dependency injection")
    func testInitializationWithDependencyInjection() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        #expect(service != nil)
    }
    
    @Test("AutoProfileUpdateService default initialization")
    func testDefaultInitialization() {
        setUp()
        
        let service = AutoProfileUpdateService()
        #expect(service != nil)
    }
    
    @Test("AutoProfileUpdateService needsAutoUpdate with no profile using mock")
    func testNeedsAutoUpdateWithNoProfileUsingMock() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Mock service returns nil profile
        mockUserProfileService.savedProfile = nil
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let needsUpdate = service.needsAutoUpdate()
        #expect(needsUpdate == false)
    }
    
    @Test("AutoProfileUpdateService needsAutoUpdate with current profile using mock")
    func testNeedsAutoUpdateWithCurrentProfileUsingMock() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Create a current profile that doesn't need update
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Animals", "Music"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            gender: .male
        )
        
        mockUserProfileService.savedProfile = profile
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let needsUpdate = service.needsAutoUpdate()
        #expect(needsUpdate == false)
    }
    
    @Test("AutoProfileUpdateService needsAutoUpdate with outdated profile using mock")
    func testNeedsAutoUpdateWithOutdatedProfileUsingMock() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Create a profile that needs stage update (newborn that's 8 months old)
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .newborn,
            interests: ["Lullabies"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            gender: .male
        )
        
        mockUserProfileService.savedProfile = profile
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let needsUpdate = service.needsAutoUpdate()
        #expect(needsUpdate == true)
    }
    
    @Test("AutoProfileUpdateService performAutoUpdate with no profile using mock")
    func testPerformAutoUpdateWithNoProfileUsingMock() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Mock service returns nil profile
        mockUserProfileService.savedProfile = nil
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let result = await service.performAutoUpdate()
        
        #expect(result.hasUpdates == false)
        #expect(result.isSuccess == true)
        #expect(result.stageProgression == nil)
        #expect(result.interestUpdate == nil)
        #expect(result.error == nil)
    }
    
    @Test("AutoProfileUpdateService performAutoUpdate with stage progression using mock")
    func testPerformAutoUpdateWithStageProgressionUsingMock() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Create a newborn profile that should progress to infant (8+ months old)
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .newborn,
            interests: ["Lullabies", "Comfort"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            gender: .male
        )
        
        mockUserProfileService.savedProfile = profile
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let result = await service.performAutoUpdate()
        
        #expect(result.isSuccess == true)
        #expect(result.hasUpdates == true)
        #expect(result.stageProgression != nil)
        #expect(result.stageProgression?.previousStage == .newborn)
        #expect(result.stageProgression?.newStage == .infant)
        #expect(result.profileMetadata != nil)
        
        // Verify profile was saved with updates
        #expect(mockUserProfileService.savedProfile?.babyStage == .infant)
        #expect(mockNotificationService.handleProfileUpdateCalled == true)
    }
    
    @Test("AutoProfileUpdateService pregnancy to newborn transition using mock")
    func testPregnancyToNewbornTransitionUsingMock() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Create a pregnancy profile that should transition to newborn
        let dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let profile = UserProfile(
            name: "Expecting Parent",
            babyStage: .pregnancy,
            interests: ["Gentle Stories", "Classical Music"],
            dueDate: dueDate,
            gender: .notSpecified
        )
        
        mockUserProfileService.savedProfile = profile
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let result = await service.performAutoUpdate()
        
        #expect(result.isSuccess == true)
        #expect(result.hasUpdates == true)
        #expect(result.stageProgression != nil)
        #expect(result.stageProgression?.previousStage == .pregnancy)
        #expect(result.stageProgression?.newStage == .newborn)
        
        // Verify dateOfBirth was set and dueDate was cleared
        #expect(mockUserProfileService.savedProfile?.dateOfBirth != nil)
        #expect(mockUserProfileService.savedProfile?.dueDate == nil)
        #expect(mockUserProfileService.savedProfile?.babyStage == .newborn)
        
        // Verify notification cancellation was called
        #expect(mockNotificationService.cancelAllDueDateNotificationsCalled == true)
    }
    
    @Test("AutoProfileUpdateService interest update with stage change using mock")
    func testInterestUpdateWithStageChangeUsingMock() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Create an infant profile that should progress to toddler
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Discovery", "Simple Sounds", "Movement"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -14, to: Date()),
            gender: .male
        )
        
        mockUserProfileService.savedProfile = profile
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let result = await service.performAutoUpdate()
        
        #expect(result.isSuccess == true)
        #expect(result.hasUpdates == true)
        #expect(result.stageProgression != nil)
        #expect(result.stageProgression?.previousStage == .infant)
        #expect(result.stageProgression?.newStage == .toddler)
        #expect(result.interestUpdate != nil)
        
        // Verify interests were updated appropriately
        let savedProfile = mockUserProfileService.savedProfile
        #expect(savedProfile?.interests.isEmpty == false)
        
        // Interests should be age-appropriate for toddler stage
        let toddlerInterests = BabyStage.toddler.availableInterests
        for interest in savedProfile?.interests ?? [] {
            #expect(toddlerInterests.contains(interest))
        }
    }
    
    @Test("AutoProfileUpdateService setupDueDateNotifications using mock")
    func testSetupDueDateNotificationsUsingMock() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        await service.setupDueDateNotifications()
        
        // Verify the notification service method was called
        #expect(mockNotificationService.setupDueDateNotificationsCalled == true)
    }
    
    @Test("AutoProfileUpdateService error handling using mock")
    func testErrorHandlingUsingMock() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Configure mock to fail on load
        mockUserProfileService.shouldFailLoad = true
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let result = await service.performAutoUpdate()
        
        #expect(result.isSuccess == false)
        #expect(result.error != nil)
        #expect(result.hasUpdates == false)
    }
    
    @Test("AutoProfileUpdateService save error handling using mock")
    func testSaveErrorHandlingUsingMock() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockNotificationService = MockDueDateNotificationService()
        
        // Create a profile that needs update
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .newborn,
            interests: ["Lullabies"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            gender: .male
        )
        
        mockUserProfileService.savedProfile = profile
        // Configure mock to fail on save
        mockUserProfileService.shouldFailSave = true
        
        let service = AutoProfileUpdateService(
            userProfileService: mockUserProfileService,
            notificationService: mockNotificationService
        )
        
        let result = await service.performAutoUpdate()
        
        #expect(result.isSuccess == false)
        #expect(result.error != nil)
    }
}
