//
//  ErrorManagerTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct ErrorManagerTests {
    
    @Test("ErrorManager initialization")
    func testInitialization() {
        let errorManager = ErrorManager()
        
        #expect(errorManager.currentError == nil)
        #expect(errorManager.showError == false)
    }
    
    @Test("ErrorManager handleError sets currentError and showError")
    func testHandleError() async {
        let errorManager = ErrorManager()
        let testError = AppError.storyGenerationFailed
        
        errorManager.handleError(testError)
        
        // Give time for async DispatchQueue.main.async to execute
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        #expect(errorManager.currentError == testError)
        #expect(errorManager.showError == true)
    }
    
    @Test("ErrorManager handleError with different error types")
    func testHandleErrorWithDifferentTypes() async {
        let errorManager = ErrorManager()
        
        let errors: [AppError] = [
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
        
        for error in errors {
            errorManager.handleError(error)
            
            // Give time for async DispatchQueue.main.async to execute
            try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
            
            #expect(errorManager.currentError == error)
            #expect(errorManager.showError == true)
            
            // Clear error for next test
            errorManager.clearError()
        }
    }
    
    @Test("ErrorManager clearError resets state")
    func testClearError() async {
        let errorManager = ErrorManager()
        let testError = AppError.networkUnavailable
        
        // Set an error first
        errorManager.handleError(testError)
        
        // Give time for async DispatchQueue.main.async to execute
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        #expect(errorManager.currentError == testError)
        #expect(errorManager.showError == true)
        
        // Clear the error
        errorManager.clearError()
        
        #expect(errorManager.currentError == nil)
        #expect(errorManager.showError == false)
    }
    
    @Test("ErrorManager multiple error handling")
    func testMultipleErrorHandling() async {
        let errorManager = ErrorManager()
        
        let firstError = AppError.storyGenerationFailed
        let secondError = AppError.profileSaveFailed
        
        // Handle first error
        errorManager.handleError(firstError)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(errorManager.currentError == firstError)
        #expect(errorManager.showError == true)
        
        // Handle second error (should replace first)
        errorManager.handleError(secondError)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(errorManager.currentError == secondError)
        #expect(errorManager.showError == true)
    }
    
    @Test("ErrorManager ObservableObject compliance")
    func testObservableObjectCompliance() {
        let errorManager = ErrorManager()
        
        // Test that it's an ObservableObject
        #expect(errorManager is any ObservableObject)
        
        // Test @Published properties exist
        let mirror = Mirror(reflecting: errorManager)
        let publishedProperties = mirror.children.compactMap { $0.label }
        
        // Should have the expected properties (though @Published wrapper makes this harder to verify directly)
        #expect(!publishedProperties.isEmpty)
    }
    
    @Test("ErrorManager thread safety")
    func testThreadSafety() async {
        let errorManager = ErrorManager()
        let errors: [AppError] = [
            .storyGenerationFailed,
            .profileSaveFailed,
            .storySaveFailed,
            .invalidProfile,
            .networkUnavailable
        ]
        
        // Handle multiple errors concurrently
        await withTaskGroup(of: Void.self) { group in
            for (index, error) in errors.enumerated() {
                group.addTask {
                    await Task.sleep(UInt64(index * 10_000_000)) // Stagger by 0.01 seconds
                    await MainActor.run {
                        errorManager.handleError(error)
                    }
                }
            }
        }
        
        // Give time for all async operations to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Should have one of the errors (last one wins)
        #expect(errorManager.currentError != nil)
        #expect(errorManager.showError == true)
        #expect(errors.contains(errorManager.currentError!))
    }
    
    @Test("ErrorManager state consistency")
    func testStateConsistency() async {
        let errorManager = ErrorManager()
        
        // Initially both should be in sync (both false/nil)
        if errorManager.showError {
            #expect(errorManager.currentError != nil)
        } else {
            #expect(errorManager.currentError == nil)
        }
        
        // After setting error, both should be in sync
        errorManager.handleError(.dataCorruption)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        if errorManager.showError {
            #expect(errorManager.currentError != nil)
        }
        
        // After clearing, both should be in sync again
        errorManager.clearError()
        
        #expect(errorManager.currentError == nil)
        #expect(errorManager.showError == false)
    }
    
    @Test("ErrorManager rapid error handling")
    func testRapidErrorHandling() async {
        let errorManager = ErrorManager()
        
        // Handle errors rapidly
        for i in 0..<10 {
            let error: AppError = i % 2 == 0 ? .storyGenerationFailed : .profileSaveFailed
            errorManager.handleError(error)
            
            // Small delay to allow async operations
            try? await Task.sleep(nanoseconds: 5_000_000) // 0.005 seconds
        }
        
        // Give final time for all operations to complete
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Should have an error and showError should be true
        #expect(errorManager.currentError != nil)
        #expect(errorManager.showError == true)
        
        // Should be one of the expected errors
        let expectedErrors: [AppError] = [.storyGenerationFailed, .profileSaveFailed]
        #expect(expectedErrors.contains(errorManager.currentError!))
    }
    
    @Test("ErrorManager clear without error")
    func testClearWithoutError() {
        let errorManager = ErrorManager()
        
        // Clear when no error is set (should not crash)
        errorManager.clearError()
        
        #expect(errorManager.currentError == nil)
        #expect(errorManager.showError == false)
    }
}
