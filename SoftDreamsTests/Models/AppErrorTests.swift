//
//  AppErrorTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct AppErrorTests {
    
    // MARK: - AppError Cases Tests
    
    @Test("Test AppError cases exist")
    func testAppErrorCases() async throws {
        // Test that all error cases are defined
        let _ = AppError.storyGenerationFailed
        let _ = AppError.profileSaveFailed
        let _ = AppError.storySaveFailed
        let _ = AppError.invalidProfile
        let _ = AppError.networkUnavailable
        let _ = AppError.dataCorruption
        let _ = AppError.dataSaveFailed
        let _ = AppError.dataExportFailed
        let _ = AppError.dataImportFailed
        let _ = AppError.invalidName
        let _ = AppError.invalidDate
        let _ = AppError.invalidStoryOptions
        let _ = AppError.invalidCharacterCount
        let _ = AppError.profileIncomplete
    }
    
    // MARK: - LocalizedError Tests
    
    @Test("Test AppError errorDescription returns localized strings")
    func testAppErrorDescriptions() async throws {
        // Test that all error descriptions are not nil and not empty
        let allErrors: [AppError] = [
            .storyGenerationFailed,
            .profileSaveFailed,
            .storySaveFailed,
            .invalidProfile,
            .networkUnavailable,
            .dataCorruption,
            .dataSaveFailed,
            .dataExportFailed,
            .dataImportFailed,
            .invalidName,
            .invalidDate,
            .invalidStoryOptions,
            .invalidCharacterCount,
            .profileIncomplete
        ]
        
        for error in allErrors {
            let description = error.errorDescription
            #expect(description != nil, "Error description should not be nil for \(error)")
            #expect(!description!.isEmpty, "Error description should not be empty for \(error)")
        }
    }
    
    @Test("Test specific AppError descriptions")
    func testSpecificAppErrorDescriptions() async throws {
        // Test specific error descriptions
        #expect(AppError.storyGenerationFailed.errorDescription != nil)
        #expect(AppError.profileSaveFailed.errorDescription != nil)
        #expect(AppError.storySaveFailed.errorDescription != nil)
        #expect(AppError.invalidProfile.errorDescription != nil)
        #expect(AppError.networkUnavailable.errorDescription != nil)
        #expect(AppError.dataCorruption.errorDescription != nil)
        #expect(AppError.dataSaveFailed.errorDescription != nil)
        #expect(AppError.dataExportFailed.errorDescription != nil)
        #expect(AppError.dataImportFailed.errorDescription != nil)
        #expect(AppError.invalidName.errorDescription != nil)
        #expect(AppError.invalidDate.errorDescription != nil)
        #expect(AppError.invalidStoryOptions.errorDescription != nil)
        #expect(AppError.invalidCharacterCount.errorDescription != nil)
        #expect(AppError.profileIncomplete.errorDescription != nil)
    }
    
    // MARK: - Equatable Tests
    
    @Test("Test AppError equality")
    func testAppErrorEquality() async throws {
        // Test same errors are equal
        #expect(AppError.storyGenerationFailed == AppError.storyGenerationFailed)
        #expect(AppError.profileSaveFailed == AppError.profileSaveFailed)
        #expect(AppError.invalidProfile == AppError.invalidProfile)
        
        // Test different errors are not equal
        #expect(AppError.storyGenerationFailed != AppError.profileSaveFailed)
        #expect(AppError.invalidProfile != AppError.networkUnavailable)
        #expect(AppError.dataCorruption != AppError.dataSaveFailed)
    }
    
    @Test("Test AppError inequality for all combinations")
    func testAppErrorInequality() async throws {
        let allErrors: [AppError] = [
            .storyGenerationFailed,
            .profileSaveFailed,
            .storySaveFailed,
            .invalidProfile,
            .networkUnavailable
        ]
        
        for i in 0..<allErrors.count {
            for j in i+1..<allErrors.count {
                #expect(allErrors[i] != allErrors[j], "\(allErrors[i]) should not equal \(allErrors[j])")
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test AppError as LocalizedError")
    func testAppErrorAsLocalizedError() async throws {
        let error: LocalizedError = AppError.networkUnavailable
        let description = error.errorDescription
        
        #expect(description != nil)
        #expect(!description!.isEmpty)
    }
    
    // MARK: - Error Categories Tests
    
    @Test("Test story-related errors")
    func testStoryRelatedErrors() async throws {
        let storyErrors: [AppError] = [
            .storyGenerationFailed,
            .storySaveFailed,
            .invalidStoryOptions
        ]
        
        for error in storyErrors {
            #expect(error.errorDescription != nil)
        }
    }
    
    @Test("Test profile-related errors")
    func testProfileRelatedErrors() async throws {
        let profileErrors: [AppError] = [
            .profileSaveFailed,
            .invalidProfile,
            .invalidName,
            .invalidDate,
            .profileIncomplete
        ]
        
        for error in profileErrors {
            #expect(error.errorDescription != nil)
        }
    }
    
    @Test("Test data-related errors")
    func testDataRelatedErrors() async throws {
        let dataErrors: [AppError] = [
            .dataCorruption,
            .dataSaveFailed,
            .dataExportFailed,
            .dataImportFailed
        ]
        
        for error in dataErrors {
            #expect(error.errorDescription != nil)
        }
    }
    
    @Test("Test network-related errors")
    func testNetworkRelatedErrors() async throws {
        let networkErrors: [AppError] = [
            .networkUnavailable
        ]
        
        for error in networkErrors {
            #expect(error.errorDescription != nil)
        }
    }
    
    @Test("Test validation errors")
    func testValidationErrors() async throws {
        let validationErrors: [AppError] = [
            .invalidName,
            .invalidDate,
            .invalidStoryOptions,
            .invalidCharacterCount,
            .profileIncomplete
        ]
        
        for error in validationErrors {
            #expect(error.errorDescription != nil)
        }
    }
}
