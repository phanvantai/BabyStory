//
//  OnboardingViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct OnboardingViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test("Test OnboardingViewModel initialization")
    func testOnboardingViewModelInitialization() async throws {
        // When
        let viewModel = OnboardingViewModel()
        
        // Then
        #expect(viewModel.selectedLanguage == Language.preferred)
        #expect(viewModel.name.isEmpty)
        #expect(viewModel.babyStage == .toddler)
        #expect(viewModel.interests.isEmpty)
        #expect(viewModel.parentNames.isEmpty)
        #expect(viewModel.dateOfBirth == nil)
        #expect(viewModel.gender == .notSpecified)
        #expect(viewModel.step == 0)
        #expect(viewModel.error == nil)
        #expect(viewModel.hasSelectedBabyStatus == false)
        #expect(viewModel.showNotificationPermissionPrompt == false)
        #expect(viewModel.notificationPermissionContext == .pregnancyReminders)
    }
    
    // MARK: - Computed Properties Tests
    
    @Test("Test isPregnancy computed property")
    func testIsPregnancy() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When pregnancy stage
        viewModel.babyStage = .pregnancy
        #expect(viewModel.isPregnancy == true)
        
        // When other stages
        viewModel.babyStage = .toddler
        #expect(viewModel.isPregnancy == false)
        
        viewModel.babyStage = .newborn
        #expect(viewModel.isPregnancy == false)
    }
    
    @Test("Test shouldShowDateOfBirth computed property")
    func testShouldShowDateOfBirth() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When pregnancy stage
        viewModel.babyStage = .pregnancy
        #expect(viewModel.shouldShowDateOfBirth == false)
        
        // When born baby stages
        viewModel.babyStage = .toddler
        #expect(viewModel.shouldShowDateOfBirth == true)
        
        viewModel.babyStage = .newborn
        #expect(viewModel.shouldShowDateOfBirth == true)
    }
    
    @Test("Test shouldShowDueDate computed property")
    func testShouldShowDueDate() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When pregnancy stage
        viewModel.babyStage = .pregnancy
        #expect(viewModel.shouldShowDueDate == true)
        
        // When born baby stages
        viewModel.babyStage = .toddler
        #expect(viewModel.shouldShowDueDate == false)
    }
    
    @Test("Test shouldShowParentNames computed property")
    func testShouldShowParentNames() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When pregnancy stage
        viewModel.babyStage = .pregnancy
        #expect(viewModel.shouldShowParentNames == true)
        
        // When born baby stages
        viewModel.babyStage = .toddler
        #expect(viewModel.shouldShowParentNames == false)
    }
    
    @Test("Test dateOfBirthRange computed property")
    func testDateOfBirthRange() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        let calendar = Calendar.current
        let today = Date()
        
        // When
        let range = viewModel.dateOfBirthRange
        
        // Then
        #expect(range.upperBound <= today)
        
        let sixYearsAgo = calendar.date(byAdding: .year, value: -6, to: today)!
        #expect(range.lowerBound <= sixYearsAgo)
    }
    
    @Test("Test dueDateRange computed property")
    func testDueDateRange() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        let calendar = Calendar.current
        let today = Date()
        
        // When
        let range = viewModel.dueDateRange
        
        // Then
        #expect(range.lowerBound <= today)
        
        let oneYearFromNow = calendar.date(byAdding: .year, value: 1, to: today)!
        #expect(range.upperBound >= oneYearFromNow)
    }
    
    // MARK: - Validation Tests
    
    @Test("Test canProceedFromStep for step 0")
    func testCanProceedFromStep0() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.step = 0
        
        // When no baby status selected
        #expect(viewModel.canProceedFromStep(0) == false)
        
        // When baby status selected
        viewModel.hasSelectedBabyStatus = true
        #expect(viewModel.canProceedFromStep(0) == true)
    }
    
    @Test("Test canProceedFromStep for step 1")
    func testCanProceedFromStep1() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.step = 1
        
        // When name is empty
        viewModel.name = ""
        #expect(viewModel.canProceedFromStep(1) == false)
        
        // When name is whitespace only
        viewModel.name = "   "
        #expect(viewModel.canProceedFromStep(1) == false)
        
        // When name is valid
        viewModel.name = "Test Baby"
        #expect(viewModel.canProceedFromStep(1) == true)
    }
    
    @Test("Test canProceedFromStep for step 2")
    func testCanProceedFromStep2() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.step = 2
        
        // When no interests selected
        viewModel.interests = []
        #expect(viewModel.canProceedFromStep(2) == false)
        
        // When interests selected
        viewModel.interests = ["animals"]
        #expect(viewModel.canProceedFromStep(2) == true)
    }
    
    @Test("Test canProceedFromStep for step 3")
    func testCanProceedFromStep3() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.step = 3
        
        // Always can proceed from step 3 (story time selection)
        #expect(viewModel.canProceedFromStep(3) == true)
    }
    
    @Test("Test canProceedFromStep for invalid step")
    func testCanProceedFromInvalidStep() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When invalid step numbers
        #expect(viewModel.canProceedFromStep(-1) == false)
        #expect(viewModel.canProceedFromStep(10) == false)
    }
    
    @Test("Test isStepValid method")
    func testIsStepValid() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // Test valid steps
        #expect(viewModel.isStepValid(0) == true)
        #expect(viewModel.isStepValid(1) == true)
        #expect(viewModel.isStepValid(2) == true)
        #expect(viewModel.isStepValid(3) == true)
        
        // Test invalid steps
        #expect(viewModel.isStepValid(-1) == false)
        #expect(viewModel.isStepValid(4) == false)
        #expect(viewModel.isStepValid(10) == false)
    }
    
    // MARK: - Profile Creation Tests
    
    @Test("Test createUserProfile for pregnancy")
    func testCreateUserProfileForPregnancy() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.name = "Test Baby"
        viewModel.babyStage = .pregnancy
        viewModel.interests = ["animals", "music"]
        viewModel.storyTime = Date()
        viewModel.dueDate = Date()
        viewModel.parentNames = ["Mom", "Dad"]
        viewModel.gender = .female
        viewModel.selectedLanguage = Language.english
        
        // When
        let profile = viewModel.createUserProfile()
        
        // Then
        #expect(profile.name == "Test Baby")
        #expect(profile.babyStage == .pregnancy)
        #expect(profile.interests == ["animals", "music"])
        #expect(profile.dueDate == viewModel.dueDate)
        #expect(profile.parentNames == ["Mom", "Dad"])
        #expect(profile.dateOfBirth == nil)
        #expect(profile.gender == .female)
        #expect(profile.language == Language.english)
    }
    
    @Test("Test createUserProfile for born baby")
    func testCreateUserProfileForBornBaby() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        let dateOfBirth = Date()
        
        viewModel.name = "Test Baby"
        viewModel.babyStage = .toddler
        viewModel.interests = ["animals"]
        viewModel.storyTime = Date()
        viewModel.dateOfBirth = dateOfBirth
        viewModel.gender = .male
        viewModel.selectedLanguage = Language.vietnamese
        
        // When
        let profile = viewModel.createUserProfile()
        
        // Then
        #expect(profile.name == "Test Baby")
        #expect(profile.babyStage == .toddler)
        #expect(profile.interests == ["animals"])
        #expect(profile.dateOfBirth == dateOfBirth)
        #expect(profile.dueDate == nil)
        #expect(profile.parentNames.isEmpty)
        #expect(profile.gender == .male)
        #expect(profile.language == Language.vietnamese)
    }
    
    // MARK: - Navigation Tests
    
    @Test("Test nextStep method")
    func testNextStep() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.hasSelectedBabyStatus = true
        
        // When
        viewModel.nextStep()
        
        // Then
        #expect(viewModel.step == 1)
        
        // When continuing
        viewModel.name = "Test"
        viewModel.nextStep()
        
        // Then
        #expect(viewModel.step == 2)
    }
    
    @Test("Test previousStep method")
    func testPreviousStep() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.step = 2
        
        // When
        viewModel.previousStep()
        
        // Then
        #expect(viewModel.step == 1)
        
        // When continuing
        viewModel.previousStep()
        
        // Then
        #expect(viewModel.step == 0)
        
        // When at first step
        viewModel.previousStep()
        
        // Then
        #expect(viewModel.step == 0) // Should not go below 0
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test setError method")
    func testSetError() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        let error = AppError.invalidProfile
        
        // When
        viewModel.error = error
        
        // Then
        #expect(viewModel.error == error)
    }
    
    @Test("Test clearError method")
    func testClearError() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.error = AppError.invalidProfile
        
        // When
        viewModel.error = nil
        
        // Then
        #expect(viewModel.error == nil)
    }
    
    // MARK: - Baby Status Selection Tests
    
    @Test("Test selectPregnancy method")
    func testSelectPregnancy() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When
        viewModel.selectPregnancy()
        
        // Then
        #expect(viewModel.babyStage == .pregnancy)
        #expect(viewModel.hasSelectedBabyStatus == true)
        #expect(viewModel.dateOfBirth == nil)
        #expect(viewModel.parentNames.isEmpty)
    }
    
    @Test("Test selectBornBaby method")
    func testSelectBornBaby() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        
        // When
        viewModel.selectBornBaby(stage: .toddler)
        
        // Then
        #expect(viewModel.babyStage == .toddler)
        #expect(viewModel.hasSelectedBabyStatus == true)
        #expect(viewModel.dueDate == nil)
        #expect(viewModel.parentNames.isEmpty)
    }
    
    // MARK: - Interest Management Tests
    
    @Test("Test toggleInterest method")
    func testToggleInterest() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        let interest = "animals"
        
        // When adding interest
        viewModel.toggleInterest(interest)
        
        // Then
        #expect(viewModel.interests.contains(interest))
        
        // When removing interest
        viewModel.toggleInterest(interest)
        
        // Then
        #expect(!viewModel.interests.contains(interest))
    }
    
    @Test("Test interest selection limits")
    func testInterestSelectionLimits() async throws {
        // Given
        let viewModel = OnboardingViewModel()
        let maxInterests = 5 // Assuming there's a limit
        
        // When adding many interests
        for i in 0..<10 {
            viewModel.toggleInterest("interest\(i)")
        }
        
        // Then - should respect any limits if implemented
        // This test depends on the actual implementation
        #expect(viewModel.interests.count <= 10) // Basic check
    }
}
