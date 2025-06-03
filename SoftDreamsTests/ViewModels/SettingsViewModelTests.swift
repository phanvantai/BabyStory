//
//  SettingsViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct SettingsViewModelTests {
    
    func setUp() {
        // Clean up UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "narrationEnabled")
        UserDefaults.standard.removeObject(forKey: "parentalLockEnabled")
        UserDefaults.standard.removeObject(forKey: "parentalPasscode")
    }
    
    @Test("SettingsViewModel initialization with dependency injection")
    func testInitializationWithDependencyInjection() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let mockSettingsService = MockSettingsService()
        let mockNotificationService = MockDueDateNotificationService()
        
        let viewModel = SettingsViewModel(
            userProfileService: mockUserProfileService,
            settingsService: mockSettingsService,
            notificationService: mockNotificationService
        )
        
        #expect(viewModel != nil)
        #expect(viewModel.appName == AppInfoService.shared.appName)
        #expect(viewModel.appVersion == AppInfoService.shared.appVersion)
    }
    
    @Test("SettingsViewModel default initialization")
    func testDefaultInitialization() {
        setUp()
        
        let viewModel = SettingsViewModel()
        
        #expect(viewModel != nil)
        #expect(viewModel.appName == AppInfoService.shared.appName)
        #expect(viewModel.appVersion == AppInfoService.shared.appVersion)
    }
    
    @Test("SettingsViewModel loads profile on initialization")
    func testLoadProfileOnInitialization() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let testProfile = UserProfile(
            name: "Test Child",
            babyStage: .toddler,
            interests: ["Stories"],
            dateOfBirth: Date(),
            gender: .notSpecified
        )
        mockUserProfileService.savedProfile = testProfile
        
        let viewModel = SettingsViewModel(
            userProfileService: mockUserProfileService,
            settingsService: MockSettingsService(),
            notificationService: MockDueDateNotificationService()
        )
        
        #expect(viewModel.profile?.name == "Test Child")
        #expect(viewModel.error == nil)
    }
    
    @Test("SettingsViewModel handles missing profile gracefully")
    func testHandlesMissingProfile() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        mockUserProfileService.savedProfile = nil
        
        let viewModel = SettingsViewModel(
            userProfileService: mockUserProfileService,
            settingsService: MockSettingsService(),
            notificationService: MockDueDateNotificationService()
        )
        
        #expect(viewModel.profile == nil)
        #expect(viewModel.error == nil)
    }
    
    @Test("SettingsViewModel handles profile load error")
    func testHandlesProfileLoadError() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        mockUserProfileService.shouldFailLoad = true
        
        let viewModel = SettingsViewModel(
            userProfileService: mockUserProfileService,
            settingsService: MockSettingsService(),
            notificationService: MockDueDateNotificationService()
        )
        
        #expect(viewModel.profile == nil)
        #expect(viewModel.error != nil)
    }
    
    @Test("SettingsViewModel loads settings on initialization")
    func testLoadSettingsOnInitialization() {
        setUp()
        
        let mockSettingsService = MockSettingsService()
        mockSettingsService.narrationEnabledValue = false
        mockSettingsService.parentalLockEnabledValue = true
        
        let viewModel = SettingsViewModel(
            userProfileService: MockUserProfileService(),
            settingsService: mockSettingsService,
            notificationService: MockDueDateNotificationService()
        )
        
        #expect(viewModel.narrationEnabled == false)
        #expect(viewModel.parentalLockEnabled == true)
    }
    
    @Test("SettingsViewModel saves profile successfully")
    func testSaveProfileSuccessfully() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let testProfile = UserProfile(
            name: "Updated Child",
            babyStage: .toddler,
            interests: ["Stories"],
            dateOfBirth: Date(),
            gender: .notSpecified
        )
        
        let viewModel = SettingsViewModel(
            userProfileService: mockUserProfileService,
            settingsService: MockSettingsService(),
            notificationService: MockDueDateNotificationService()
        )
        
        viewModel.saveProfile(testProfile)
        
        #expect(mockUserProfileService.savedProfile?.name == "Updated Child")
        #expect(viewModel.profile?.name == "Updated Child")
        #expect(viewModel.error == nil)
    }
    
    @Test("SettingsViewModel handles profile save error")
    func testHandlesProfileSaveError() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        mockUserProfileService.shouldFailSave = true
        
        let testProfile = UserProfile(
            name: "Test Child",
            babyStage: .toddler,
            interests: ["Stories"],
            dateOfBirth: Date(),
            gender: .notSpecified
        )
        
        let viewModel = SettingsViewModel(
            userProfileService: mockUserProfileService,
            settingsService: MockSettingsService(),
            notificationService: MockDueDateNotificationService()
        )
        
        viewModel.saveProfile(testProfile)
        
        #expect(viewModel.error == .profileSaveFailed)
    }
    
    @Test("SettingsViewModel saves narration enabled setting")
    func testSaveNarrationEnabled() {
        setUp()
        
        let mockSettingsService = MockSettingsService()
        
        let viewModel = SettingsViewModel(
            userProfileService: MockUserProfileService(),
            settingsService: mockSettingsService,
            notificationService: MockDueDateNotificationService()
        )
        
        viewModel.saveNarrationEnabled(false)
        
        #expect(viewModel.narrationEnabled == false)
        #expect(mockSettingsService.saveNarrationEnabledCalled == true)
        #expect(mockSettingsService.savedNarrationEnabled == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("SettingsViewModel handles narration enabled save error")
    func testHandlesNarrationEnabledSaveError() {
        setUp()
        
        let mockSettingsService = MockSettingsService()
        mockSettingsService.shouldFailSave = true
        
        let viewModel = SettingsViewModel(
            userProfileService: MockUserProfileService(),
            settingsService: mockSettingsService,
            notificationService: MockDueDateNotificationService()
        )
        
        viewModel.saveNarrationEnabled(false)
        
        #expect(viewModel.error == .dataSaveFailed)
    }
    
    @Test("SettingsViewModel opens support website")
    func testOpenSupportWebsite() {
        setUp()
        
        let viewModel = SettingsViewModel(
            userProfileService: MockUserProfileService(),
            settingsService: MockSettingsService(),
            notificationService: MockDueDateNotificationService()
        )
        
        // This should not crash - just testing the method exists and can be called
        viewModel.openSupportWebsite()
        #expect(true) // Test passes if no crash occurs
    }
    
    @Test("SettingsViewModel notification permission methods exist")
    func testNotificationPermissionMethods() async {
        setUp()
        
        let viewModel = SettingsViewModel(
            userProfileService: MockUserProfileService(),
            settingsService: MockSettingsService(),
            notificationService: MockDueDateNotificationService()
        )
        
        // Test that these methods exist and can be called without crashing
        await viewModel.handleNotificationPermissionGranted()
        viewModel.handleNotificationPermissionDenied()
        
        #expect(true) // Test passes if no crash occurs
    }
}
