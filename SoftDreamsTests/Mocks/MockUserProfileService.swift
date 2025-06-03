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
    
    func saveProfile(_ profile: UserProfile) throws {
        if shouldFailSave {
            throw AppError.profileSaveFailed
        }
        savedProfile = profile
    }
    
    func loadProfile() throws -> UserProfile? {
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
