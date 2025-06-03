//
//  AutoUpdateSettingsViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct AutoUpdateSettingsViewModelTests {
    
    // MARK: - Test Initialization
    
    @Test("ViewModel should initialize with default settings on first launch")
    func testViewModel_OnFirstLaunch_ShouldSetUserFriendlyDefaults() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        mockSettingsService.hasInitializedSettingsResult = false
        
        // When
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        // Then
        #expect(viewModel.autoUpdateEnabled == true)
        #expect(viewModel.stageProgressionEnabled == true)
        #expect(viewModel.interestUpdatesEnabled == true)
        #expect(mockSettingsService.saveSettingsCalled == true)
    }
    
    @Test("ViewModel should load existing settings on subsequent launches")
    func testViewModel_OnSubsequentLaunch_ShouldLoadExistingSettings() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        mockSettingsService.hasInitializedSettingsResult = true
        mockSettingsService.autoUpdateEnabledResult = false
        mockSettingsService.stageProgressionEnabledResult = true
        mockSettingsService.interestUpdatesEnabledResult = false
        
        // When
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        // Then
        #expect(viewModel.autoUpdateEnabled == false)
        #expect(viewModel.stageProgressionEnabled == true)
        #expect(viewModel.interestUpdatesEnabled == false)
    }
    
    // MARK: - Test Settings Changes
    
    @Test("ViewModel should save settings when auto update is toggled")
    func testViewModel_WhenAutoUpdateToggled_ShouldSaveSettings() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        mockSettingsService.saveSettingsCalled = false
        
        // When
        viewModel.autoUpdateEnabled = false
        
        // Then
        #expect(mockSettingsService.saveSettingsCalled == true)
        #expect(mockSettingsService.savedAutoUpdateEnabled == false)
    }
    
    @Test("ViewModel should save settings when stage progression is toggled")
    func testViewModel_WhenStageProgressionToggled_ShouldSaveSettings() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        mockSettingsService.saveSettingsCalled = false
        
        // When
        viewModel.stageProgressionEnabled = false
        
        // Then
        #expect(mockSettingsService.saveSettingsCalled == true)
        #expect(mockSettingsService.savedStageProgressionEnabled == false)
    }
    
    // MARK: - Test Manual Update
    
    @Test("ViewModel should perform manual update successfully")
    func testViewModel_WhenPerformManualUpdate_ShouldUpdateSuccessfully() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        // Setup a successful update result with 3 updates
        var updateResult = AutoUpdateResult()
        updateResult.stageProgression = StageProgressionUpdate(
            previousStage: .newborn,
            newStage: .infant,
            ageInMonths: 8,
            growthMessage: "Test growth message"
        )
        updateResult.interestUpdate = InterestUpdate(
            previousInterests: ["Old Interest"],
            newInterests: ["New Interest 1", "New Interest 2"],
            removedInterests: ["Old Interest"],
            addedInterests: ["New Interest 1", "New Interest 2"]
        )
        updateResult.profileMetadata = ProfileMetadataUpdate(
            previousLastUpdate: Date().addingTimeInterval(-86400),
            newLastUpdate: Date()
        )
        mockAutoUpdateService.performAutoUpdateResult = updateResult
        
        // Setup mock profile service to return a valid profile
        let testProfile = UserProfile(name: "Test User")
        mockProfileService.loadProfileResult = .success(testProfile)
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        // When
        await viewModel.performManualUpdate()
        
        // Then
        #expect(viewModel.isCheckingForUpdates == false)
        #expect(viewModel.showUpdateResult == true)
        #expect(viewModel.updateResultMessage.contains("3"))
        #expect(mockAutoUpdateService.performAutoUpdateCalled == true)
    }
    
    @Test("ViewModel should handle manual update with no updates")
    func testViewModel_WhenPerformManualUpdateWithNoUpdates_ShouldShowNoUpdatesMessage() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        // Setup a successful result but with no updates (default AutoUpdateResult)
        let updateResult = AutoUpdateResult()
        mockAutoUpdateService.performAutoUpdateResult = updateResult
        
        // Setup mock profile service to return a valid profile
        let testProfile = UserProfile(name: "Test User")
        mockProfileService.loadProfileResult = .success(testProfile)
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        // When
        await viewModel.performManualUpdate()
        
        // Then
        #expect(viewModel.showUpdateResult == true)
        #expect(viewModel.updateResultMessage == "auto_update_no_updates_message".localized)
    }
    
    @Test("ViewModel should handle manual update failure")
    func testViewModel_WhenPerformManualUpdateFails_ShouldShowErrorMessage() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        // Setup a failed update result with an error
        var updateResult = AutoUpdateResult()
        updateResult.error = AppError.dataCorruption // Set an error to simulate failure
        mockAutoUpdateService.performAutoUpdateResult = updateResult
        
        // Setup mock profile service to return a valid profile
        let testProfile = UserProfile(name: "Test User")
        mockProfileService.loadProfileResult = .success(testProfile)
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        // When
        await viewModel.performManualUpdate()
        
        // Then
        #expect(viewModel.showUpdateResult == true)
        #expect(viewModel.updateResultMessage == "auto_update_failed_message".localized)
    }
    
    // MARK: - Test Last Update Info
    
    @Test("ViewModel should return formatted last update info when profile exists")
    func testViewModel_WhenProfileExists_ShouldReturnFormattedLastUpdateInfo() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
        let testDate = Date()
        let mockProfile = UserProfile(
          name: "Test User",
          lastUpdate: testDate
        )
        mockProfileService.loadProfileResult = .success(mockProfile)
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        // When
        let lastUpdateInfo = viewModel.lastUpdateInfo
        
        // Then
        #expect(lastUpdateInfo != nil)
        #expect(mockProfileService.loadProfileCalled == true)
    }
    
    @Test("ViewModel should return nil when profile loading fails")
    func testViewModel_WhenProfileLoadingFails_ShouldReturnNilLastUpdateInfo() async {
        // Given
        let mockSettingsService = MockAutoUpdateSettingsService()
        let mockProfileService = MockUserProfileService()
        let mockAutoUpdateService = MockAutoProfileUpdateService()
        
      mockProfileService.loadProfileResult = .failure(AppError.dataCorruption)
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            autoUpdateService: mockAutoUpdateService, userProfileService: mockProfileService
        )
        
        // When
        let lastUpdateInfo = viewModel.lastUpdateInfo
        
        // Then
        #expect(lastUpdateInfo == nil)
    }
}
