//
//  StringExtensionsTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct StringExtensionsTests {
    
    // MARK: - Localized Property Tests
    
    @Test("Test localized property returns localized string for valid key")
    func testLocalizedPropertyWithValidKey() async throws {
        // Given
        let key = "language_selection_title"
        
        // When
        let localizedString = key.localized
        
        // Then
        #expect(localizedString == "Welcome to SoftDreams", "Should return the English localized string")
        #expect(localizedString != key, "Localized string should be different from the key")
    }
    
    @Test("Test localized property returns original key for invalid key")
    func testLocalizedPropertyWithInvalidKey() async throws {
        // Given
        let invalidKey = "this_key_does_not_exist_in_localizable"
        
        // When
        let localizedString = invalidKey.localized
        
        // Then
        #expect(localizedString == invalidKey, "Should return the original key when no localization exists")
    }
    
    @Test("Test localized property with empty string")
    func testLocalizedPropertyWithEmptyString() async throws {
        // Given
        let emptyKey = ""
        
        // When
        let localizedString = emptyKey.localized
        
        // Then
        #expect(localizedString == "", "Empty string should return empty string")
    }
    
    @Test("Test localized property with special characters")
    func testLocalizedPropertyWithSpecialCharacters() async throws {
        // Given
        let specialKey = "special_@#$%_key"
        
        // When
        let localizedString = specialKey.localized
        
        // Then
        #expect(localizedString == specialKey, "Should return the original key for special characters")
    }
    
    @Test("Test localized property with whitespace")
    func testLocalizedPropertyWithWhitespace() async throws {
        // Given
        let whitespaceKey = "  key_with_spaces  "
        
        // When
        let localizedString = whitespaceKey.localized
        
        // Then
        #expect(localizedString == whitespaceKey, "Should preserve whitespace when no localization exists")
    }
    
    @Test("Test localized property with known onboarding keys")
    func testLocalizedPropertyWithKnownOnboardingKeys() async throws {
        // Given
        let keys = [
            "choose_language",
            "current_selection",
            "onboarding_welcome_welcome_to"
        ]
        
        // When & Then
        for key in keys {
            let localizedString = key.localized
            #expect(localizedString != key, "Key '\(key)' should have a localized value")
            #expect(!localizedString.isEmpty, "Localized string should not be empty")
        }
    }
    
    @Test("Test localized property consistency")
    func testLocalizedPropertyConsistency() async throws {
        // Given
        let key = "language_selection_subtitle"
        
        // When
        let firstCall = key.localized
        let secondCall = key.localized
        
        // Then
        #expect(firstCall == secondCall, "Multiple calls should return the same result")
    }
    
    @Test("Test localized property case sensitivity")
    func testLocalizedPropertyCaseSensitivity() async throws {
        // Given
        let lowerKey = "choose_language"
        let upperKey = "CHOOSE_LANGUAGE"
        
        // When
        let lowerResult = lowerKey.localized
        let upperResult = upperKey.localized
        
        // Then
        #expect(lowerResult != upperResult, "Localization should be case sensitive")
        #expect(upperResult == upperKey, "Uppercase key should return itself when not found")
    }
    
    @Test("Test localized property with numeric strings")
    func testLocalizedPropertyWithNumericStrings() async throws {
        // Given
        let numericKey = "12345"
        
        // When
        let localizedString = numericKey.localized
        
        // Then
        #expect(localizedString == numericKey, "Numeric keys should return themselves")
    }
    
    @Test("Test localized property with long strings")
    func testLocalizedPropertyWithLongStrings() async throws {
        // Given
        let longKey = String(repeating: "a", count: 1000)
        
        // When
        let localizedString = longKey.localized
        
        // Then
        #expect(localizedString == longKey, "Long keys should return themselves when not found")
        #expect(localizedString.count == 1000, "Length should be preserved")
    }
    
    // MARK: - Performance Tests
    
    @Test("Test localized property performance")
    func testLocalizedPropertyPerformance() async throws {
        // Given
        let key = "language_selection_title"
        let iterations = 1000
        
        // When
        let startTime = Date()
        for _ in 0..<iterations {
            _ = key.localized
        }
        let endTime = Date()
        
        // Then
        let timeInterval = endTime.timeIntervalSince(startTime)
        #expect(timeInterval < 1.0, "1000 localizations should complete in less than 1 second")
    }
    
    // MARK: - Thread Safety Tests
    
    @Test("Test localized property thread safety")
    func testLocalizedPropertyThreadSafety() async throws {
        // Given
        let key = "language_selection_title"
        let expectation = 10
        var results: [String] = []
        
        // When
        await withTaskGroup(of: String.self) { group in
            for _ in 0..<expectation {
                group.addTask {
                    return key.localized
                }
            }
            
            for await result in group {
                results.append(result)
            }
        }
        
        // Then
        #expect(results.count == expectation, "Should have received all results")
        let uniqueResults = Set(results)
        #expect(uniqueResults.count == 1, "All results should be identical")
    }
}
