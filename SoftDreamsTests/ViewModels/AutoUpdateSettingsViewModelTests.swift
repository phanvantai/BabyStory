//
//  AutoUpdateSettingsViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Testing
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
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
        
        let updateResult = AutoUpdateResult(isSuccess: true, hasUpdates: true, updateCount: 3, errorMessage: nil)
        mockAutoUpdateService.performAutoUpdateResult = updateResult
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
        
        let updateResult = AutoUpdateResult(isSuccess: true, hasUpdates: false, updateCount: 0, errorMessage: nil)
        mockAutoUpdateService.performAutoUpdateResult = updateResult
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
        
        let updateResult = AutoUpdateResult(isSuccess: false, hasUpdates: false, updateCount: 0, errorMessage: "Network error")
        mockAutoUpdateService.performAutoUpdateResult = updateResult
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
            name: "Test",
            age: 5,
            interests: [],
            avatar: "test",
            language: .english,
            lastUpdate: testDate
        )
        mockProfileService.loadProfileResult = .success(mockProfile)
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
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
        
        mockProfileService.loadProfileResult = .failure(AppError.dataNotFound)
        
        let viewModel = AutoUpdateSettingsViewModel(
            settingsService: mockSettingsService,
            profileService: mockProfileService,
            autoUpdateService: mockAutoUpdateService
        )
        
        // When
        let lastUpdateInfo = viewModel.lastUpdateInfo
        
        // Then
        #expect(lastUpdateInfo == nil)
    }
}