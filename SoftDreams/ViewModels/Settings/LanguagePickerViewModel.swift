//
//  LanguagePickerViewModel.swift
//  SoftDreams
//
//  Created by Tai Phan Van
//

import Foundation

/// ViewModel for the LanguagePicker component
@MainActor
class LanguagePickerViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let userProfileService: UserProfileServiceProtocol
    private let languageManager: any LanguageManagerProtocol
    
    // MARK: - Published Properties
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var selectedLanguage: Language {
        Language.allCases.first { $0.code == languageManager.currentLanguage } ?? Language.preferred
    }
    
    // MARK: - Initialization
    init(
        userProfileService: UserProfileServiceProtocol = ServiceFactory.shared.createUserProfileService(),
        languageManager: any LanguageManagerProtocol = LanguageManager.shared
    ) {
        self.userProfileService = userProfileService
        self.languageManager = languageManager
    }
    
    // MARK: - Public Methods
    
    /// Selects a new language and updates both the language manager and user profile
    /// - Parameter language: The language to select
    func selectLanguage(_ language: Language) async {
        // Update LanguageManager for immediate UI changes
        languageManager.updateLanguage(language.code)
        
        // Update UserProfile if it exists
        await updateProfileLanguage(language)
    }
    
    /// Clears any error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func updateProfileLanguage(_ language: Language) async {
        do {
            try userProfileService.updateProfile { profile in
                profile.language = language
            }
            Logger.info("Profile language updated to: \(language.code)", category: .userProfile)
        } catch {
            let errorMsg = "Failed to update profile language: \(error.localizedDescription)"
            errorMessage = errorMsg
            Logger.error(errorMsg, category: .userProfile)
        }
    }
}
