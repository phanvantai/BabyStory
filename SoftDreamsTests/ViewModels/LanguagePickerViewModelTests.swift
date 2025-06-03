//
//  LanguagePickerViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct LanguagePickerViewModelTests {
    
    @Test("LanguagePickerViewModel initialization")
    func testInitialization() {
        let mockUserProfileService = MockUserProfileService()
        let mockLanguageManager = MockLanguageManager()
        
        let viewModel = LanguagePickerViewModel(
            userProfileService: mockUserProfileService,
            languageManager: mockLanguageManager
        )
        
        #expect(viewModel.errorMessage == nil)
        // MockLanguageManager initializes with currentLanguage = "en"
        #expect(viewModel.selectedLanguage == Language.english)
    }
    
    @Test("LanguagePickerViewModel selectedLanguage computation")
    func testSelectedLanguageComputation() {
        let mockUserProfileService = MockUserProfileService()
        let mockLanguageManager = MockLanguageManager()
        mockLanguageManager.currentLanguage = "vi"
        
        let viewModel = LanguagePickerViewModel(
            userProfileService: mockUserProfileService,
            languageManager: mockLanguageManager
        )
        
      #expect(viewModel.selectedLanguage == Language.vietnamese)
    }
    
    @Test("LanguagePickerViewModel selectLanguage success")
    func testSelectLanguageSuccess() async {
        let mockUserProfileService = MockUserProfileService()
        let mockLanguageManager = MockLanguageManager()
        
        // Setup existing profile
        let existingProfile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["animals"],
            gender: .male
        )
        mockUserProfileService.savedProfile = existingProfile
        
        let viewModel = LanguagePickerViewModel(
            userProfileService: mockUserProfileService,
            languageManager: mockLanguageManager
        )
        
      await viewModel.selectLanguage(.vietnamese)
        
        #expect(mockLanguageManager.updatedLanguage == "vi")
      #expect(mockUserProfileService.savedProfile?.language == Language.vietnamese)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("LanguagePickerViewModel selectLanguage without existing profile")
    func testSelectLanguageWithoutExistingProfile() async {
        let mockUserProfileService = MockUserProfileService()
        let mockLanguageManager = MockLanguageManager()
        
        // No existing profile
        mockUserProfileService.savedProfile = nil
        
        let viewModel = LanguagePickerViewModel(
            userProfileService: mockUserProfileService,
            languageManager: mockLanguageManager
        )
        
        await viewModel.selectLanguage(.vietnamese)
        
        #expect(mockLanguageManager.updatedLanguage == "vi")
        #expect(mockUserProfileService.savedProfile == nil)
        // When there's no profile to update, an error should be set
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("Failed to update profile language") == true)
    }
    
    @Test("LanguagePickerViewModel selectLanguage failure")
    func testSelectLanguageFailure() async {
        let mockUserProfileService = MockUserProfileService()
        let mockLanguageManager = MockLanguageManager()
        
        // Setup existing profile and force error
        let existingProfile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["animals"],
            gender: .male
        )
        mockUserProfileService.savedProfile = existingProfile
        mockUserProfileService.shouldFailUpdate = true
        
        let viewModel = LanguagePickerViewModel(
            userProfileService: mockUserProfileService,
            languageManager: mockLanguageManager
        )
        
      await viewModel.selectLanguage(.vietnamese)
        
        #expect(mockLanguageManager.updatedLanguage == "vi")
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("Failed to update profile language") == true)
    }
    
    @Test("LanguagePickerViewModel clearError")
    func testClearError() {
        let mockUserProfileService = MockUserProfileService()
        let mockLanguageManager = MockLanguageManager()
        
        let viewModel = LanguagePickerViewModel(
            userProfileService: mockUserProfileService,
            languageManager: mockLanguageManager
        )
        
        viewModel.errorMessage = "Test error"
        #expect(viewModel.errorMessage == "Test error")
        
        viewModel.clearError()
        #expect(viewModel.errorMessage == nil)
    }
}
