//
//  MockUserProfileService.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
@testable import SoftDreams

// MARK: - Mock User Profile Service for Testing
class MockUserProfileService: UserProfileServiceProtocol {
    var savedProfile: UserProfile?
    var shouldFailSave = false
    var shouldFailLoad = false
    var shouldFailUpdate = false
    
    // For testing purposes
    var loadProfileResult: Result<UserProfile?, AppError>?
    var loadProfileCalled = false
    
    func saveProfile(_ profile: UserProfile) throws {
        if shouldFailSave {
            throw AppError.profileSaveFailed
        }
        savedProfile = profile
    }
    
    func loadProfile() throws -> UserProfile? {
        loadProfileCalled = true
        
        if let result = loadProfileResult {
            switch result {
            case .success(let profile):
                return profile
            case .failure(let error):
                throw error
            }
        }
        
        if shouldFailLoad {
            throw AppError.dataCorruption
        }
        return savedProfile
    }
    
    func updateProfile(_ updates: (inout UserProfile) -> Void) throws {
        if shouldFailUpdate {
            throw AppError.profileSaveFailed
        }
        
        guard var profile = savedProfile else {
            throw AppError.invalidProfile
        }
        
        updates(&profile)
        savedProfile = profile
    }
}
