//
//  GenderTests.swift
//  SoftDreamsTests
//
//  Created by AI Assistant on 2/6/25.
//

import XCTest
@testable import SoftDreams

final class GenderTests: XCTestCase {
    
    func testGenderRawValues() {
        // Test all raw values are correct
        XCTAssertEqual(Gender.male.rawValue, "male")
        XCTAssertEqual(Gender.female.rawValue, "female")
        XCTAssertEqual(Gender.notSpecified.rawValue, "not_specified")
    }
    
    func testGenderDisplayNames() {
        // Test all display names return localized strings
        XCTAssertNotNil(Gender.male.displayName)
        XCTAssertNotNil(Gender.female.displayName)
        XCTAssertNotNil(Gender.notSpecified.displayName)
        
        // Ensure display names are not empty
        XCTAssertFalse(Gender.male.displayName.isEmpty)
        XCTAssertFalse(Gender.female.displayName.isEmpty)
        XCTAssertFalse(Gender.notSpecified.displayName.isEmpty)
    }
    
    func testGenderPronouns() {
        // Test all pronouns return localized strings
        XCTAssertNotNil(Gender.male.pronoun)
        XCTAssertNotNil(Gender.female.pronoun)
        XCTAssertNotNil(Gender.notSpecified.pronoun)
        
        // Ensure pronouns are not empty
        XCTAssertFalse(Gender.male.pronoun.isEmpty)
        XCTAssertFalse(Gender.female.pronoun.isEmpty)
        XCTAssertFalse(Gender.notSpecified.pronoun.isEmpty)
    }
    
    func testGenderPossessivePronouns() {
        // Test all possessive pronouns return localized strings
        XCTAssertNotNil(Gender.male.possessivePronoun)
        XCTAssertNotNil(Gender.female.possessivePronoun)
        XCTAssertNotNil(Gender.notSpecified.possessivePronoun)
        
        // Ensure possessive pronouns are not empty
        XCTAssertFalse(Gender.male.possessivePronoun.isEmpty)
        XCTAssertFalse(Gender.female.possessivePronoun.isEmpty)
        XCTAssertFalse(Gender.notSpecified.possessivePronoun.isEmpty)
    }
    
    func testGenderAllCases() {
        // Test that all cases are included
        let allCases = Gender.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.male))
        XCTAssertTrue(allCases.contains(.female))
        XCTAssertTrue(allCases.contains(.notSpecified))
    }
    
    func testGenderCodeable() throws {
        // Test encoding and decoding for all cases
        for gender in Gender.allCases {
            let encodedData = try JSONEncoder().encode(gender)
            XCTAssertNotNil(encodedData)
            
            let decodedGender = try JSONDecoder().decode(Gender.self, from: encodedData)
            XCTAssertEqual(gender, decodedGender)
        }
    }
    
    func testGenderFromRawValue() {
        // Test creating from raw values
        XCTAssertEqual(Gender(rawValue: "male"), .male)
        XCTAssertEqual(Gender(rawValue: "female"), .female)
        XCTAssertEqual(Gender(rawValue: "not_specified"), .notSpecified)
        
        // Test invalid raw value
        XCTAssertNil(Gender(rawValue: "invalid"))
        XCTAssertNil(Gender(rawValue: ""))
        XCTAssertNil(Gender(rawValue: "other"))
    }
    
    func testGenderEquality() {
        // Test equality
        XCTAssertEqual(Gender.male, Gender.male)
        XCTAssertEqual(Gender.female, Gender.female)
        XCTAssertEqual(Gender.notSpecified, Gender.notSpecified)
        
        // Test inequality
        XCTAssertNotEqual(Gender.male, Gender.female)
        XCTAssertNotEqual(Gender.male, Gender.notSpecified)
        XCTAssertNotEqual(Gender.female, Gender.notSpecified)
    }
    
    func testGenderStringConformance() {
        // Test that Gender conforms to various protocols appropriately
        for gender in Gender.allCases {
            // Should be hashable
            let hashValue = gender.hashValue
            XCTAssertNotNil(hashValue)
            
            // Should have string representation
            let description = String(describing: gender)
            XCTAssertFalse(description.isEmpty)
        }
    }
    
    func testGenderLocalizationConsistency() {
        // Test that all localized properties exist and are consistent
        for gender in Gender.allCases {
            // All properties should return non-empty strings
            XCTAssertFalse(gender.displayName.isEmpty, "Display name should not be empty for \(gender)")
            XCTAssertFalse(gender.pronoun.isEmpty, "Pronoun should not be empty for \(gender)")
            XCTAssertFalse(gender.possessivePronoun.isEmpty, "Possessive pronoun should not be empty for \(gender)")
            
            // Properties should be different (unless intentionally the same)
            // Note: In some languages, these might be the same, so we just check they exist
            XCTAssertNotNil(gender.displayName)
            XCTAssertNotNil(gender.pronoun)
            XCTAssertNotNil(gender.possessivePronoun)
        }
    }
}
