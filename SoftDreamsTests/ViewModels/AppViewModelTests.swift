//
//  AppViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct AppViewModelTests {
    
    func setUp() {
        // Clean up UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "stories")
        UserDefaults.standard.removeObject(forKey: "settings")
    }
    
    // MARK: - Initialization Tests
    
    @Test("AppViewModel initialization with default state")
    func testAppViewModelInitialization() {
        setUp()
        
        let viewModel = AppViewModel()
        
        #expect(viewModel.needsOnboarding == true)
        #expect(viewModel.isLoading == true)
        #expect(viewModel.currentError == nil)
    }
    
    @Test("AppViewModel initialization with dependency injection")
    func testAppViewModelInitializationWithDependencyInjection() {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let errorManager = ErrorManager()
        
        let viewModel = AppViewModel(
            userProfileService: mockUserProfileService,
            errorManager: errorManager
        )
        
        #expect(viewModel.needsOnboarding == true)
        #expect(viewModel.isLoading == true)
        #expect(viewModel.currentError == nil)
    }
    
    // MARK: - Load Initial Data Tests
    
    @Test("AppViewModel loadInitialData with no profile shows onboarding")
    func testLoadInitialDataWithNoProfileShowsOnboarding() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        mockUserProfileService.savedProfile = nil
        
        let viewModel = AppViewModel(userProfileService: mockUserProfileService)
        
        await viewModel.loadInitialData()
        
        #expect(viewModel.needsOnboarding == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.currentError == nil)
    }
    
    @Test("AppViewModel loadInitialData with existing profile proceeds to home")
    func testLoadInitialDataWithExistingProfileProceedsToHome() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["Animals"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -18, to: Date()),
            gender: .male
        )
        mockUserProfileService.savedProfile = profile
        
        let viewModel = AppViewModel(userProfileService: mockUserProfileService)
        
        await viewModel.loadInitialData()
        
        #expect(viewModel.needsOnboarding == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.currentError == nil)
    }
    
    @Test("AppViewModel loadInitialData with error shows onboarding and sets error")
    func testLoadInitialDataWithErrorShowsOnboardingAndSetsError() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        mockUserProfileService.shouldFailLoad = true
        
        let viewModel = AppViewModel(userProfileService: mockUserProfileService)
        
        await viewModel.loadInitialData()
        
        #expect(viewModel.needsOnboarding == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.currentError == .dataCorruption)
    }
    
    // MARK: - Scene Phase Change Tests
    
    @Test("AppViewModel handleScenePhaseChange from background to active refreshes data")
    func testHandleScenePhaseChangeFromBackgroundToActiveRefreshesData() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["Animals"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -18, to: Date()),
            gender: .male
        )
        mockUserProfileService.savedProfile = profile
        
        let viewModel = AppViewModel(userProfileService: mockUserProfileService)
        
        // Set initial state as if app already loaded
        await viewModel.loadInitialData()
        
        // Verify initial state
        #expect(viewModel.needsOnboarding == false)
        #expect(viewModel.isLoading == false)
        
        // Simulate app going to background and then active
        await viewModel.handleScenePhaseChange(from: .background, to: .active)
        
        // Verify no state change occurred (should just refresh data silently)
        #expect(viewModel.needsOnboarding == false)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("AppViewModel handleScenePhaseChange ignores other transitions")
    func testHandleScenePhaseChangeIgnoresOtherTransitions() async {
        setUp()
        
        let viewModel = AppViewModel()
        
        // These should not trigger any actions
        await viewModel.handleScenePhaseChange(from: .active, to: .background)
        await viewModel.handleScenePhaseChange(from: .active, to: .inactive)
        await viewModel.handleScenePhaseChange(from: .inactive, to: .active)
        
        // Verify no state changes occurred
        #expect(viewModel.needsOnboarding == true) // Initial state
        #expect(viewModel.isLoading == true) // Initial state
    }
    
    // MARK: - Onboarding Complete Tests
    
    @Test("AppViewModel onboardingComplete updates state correctly")
    func testOnboardingCompleteUpdatesStateCorrectly() async {
        setUp()
        
        let viewModel = AppViewModel()
        
        // Set state as if in onboarding
        viewModel.needsOnboarding = true
        viewModel.isLoading = false
        
        await viewModel.onboardingComplete()
        
        #expect(viewModel.needsOnboarding == false)
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("AppViewModel handleError sets error state correctly")
    func testHandleErrorSetsErrorStateCorrectly() {
        setUp()
        
        let errorManager = ErrorManager()
        let viewModel = AppViewModel(errorManager: errorManager)
        
        viewModel.handleError(.networkUnavailable)
        
        #expect(viewModel.currentError == .networkUnavailable)
        #expect(errorManager.currentError == .networkUnavailable)
        #expect(errorManager.showError == true)
    }
    
    @Test("AppViewModel clearError clears error state correctly")
    func testClearErrorClearsErrorStateCorrectly() {
        setUp()
        
        let errorManager = ErrorManager()
        let viewModel = AppViewModel(errorManager: errorManager)
        
        // Set an error first
        viewModel.handleError(.networkUnavailable)
        #expect(viewModel.currentError == .networkUnavailable)
        
        // Clear the error
        viewModel.clearError()
        
        #expect(viewModel.currentError == nil)
        #expect(errorManager.currentError == nil)
        #expect(errorManager.showError == false)
    }
    
    // MARK: - Integration Tests
    
    @Test("AppViewModel full app lifecycle flow")
    func testFullAppLifecycleFlow() async {
        setUp()
        
        let mockUserProfileService = MockUserProfileService()
        let viewModel = AppViewModel(userProfileService: mockUserProfileService)
        
        // 1. Initial app load with no profile (should show onboarding)
        await viewModel.loadInitialData()
        #expect(viewModel.needsOnboarding == true)
        #expect(viewModel.isLoading == false)
        
        // 2. Create and save profile (simulate onboarding completion)
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["Animals"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -18, to: Date()),
            gender: .male
        )
        mockUserProfileService.savedProfile = profile
        
        // 3. Complete onboarding
        await viewModel.onboardingComplete()
        #expect(viewModel.needsOnboarding == false)
        
        // 4. Simulate app going to background and returning
        await viewModel.handleScenePhaseChange(from: .background, to: .active)
        #expect(viewModel.needsOnboarding == false)
        #expect(viewModel.isLoading == false)
    }
}
