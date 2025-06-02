//
//  ProfileValidationTests.swift
//  SoftDreamsTests
//
//  Created by AI Assistant on 2/6/25.
//

import XCTest
@testable import SoftDreams

final class ProfileValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset UserDefaults before each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up UserDefaults after each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    // MARK: - ProfileValidationRules Tests
    
    func testProfileValidationRulesConstants() {
        XCTAssertEqual(ProfileValidationRules.minNameLength, 1)
        XCTAssertEqual(ProfileValidationRules.maxNameLength, 50)
        XCTAssertEqual(ProfileValidationRules.maxCharactersInStory, 5)
        XCTAssertEqual(ProfileValidationRules.maxInterests, 10)
        XCTAssertEqual(ProfileValidationRules.maxParentNames, 2)
        XCTAssertEqual(ProfileValidationRules.maxChildAgeYears, 10)
        XCTAssertEqual(ProfileValidationRules.storyTimeValidHours, 0...23)
        XCTAssertEqual(ProfileValidationRules.storyTimeValidMinutes, 0...59)
    }
    
    func testProfileValidationRulesDateRanges() {
        let maxDueDate = ProfileValidationRules.maxDueDateFuture
        let minDueDate = ProfileValidationRules.minDueDatePast
        let maxChildAge = ProfileValidationRules.maxChildAge
        
        // Max due date should be in the future
        XCTAssertGreaterThan(maxDueDate, Date())
        
        // Min due date should be in the past
        XCTAssertLessThan(minDueDate, Date())
        
        // Max child age should be in the past
        XCTAssertLessThan(maxChildAge, Date())
    }
    
    // MARK: - ValidationResult Tests
    
    func testValidationResultInitialization() {
        // Test with no errors or warnings
        let result1 = ValidationResult()
        XCTAssertTrue(result1.isValid)
        XCTAssertTrue(result1.errors.isEmpty)
        XCTAssertTrue(result1.warnings.isEmpty)
        XCTAssertFalse(result1.hasWarnings)
        XCTAssertNil(result1.primaryError)
        XCTAssertNil(result1.primaryWarning)
        
        // Test with errors
        let errors = [AppError.invalidName, AppError.invalidDate]
        let result2 = ValidationResult(errors: errors)
        XCTAssertFalse(result2.isValid)
        XCTAssertEqual(result2.errors.count, 2)
        XCTAssertEqual(result2.primaryError, .invalidName)
        
        // Test with warnings
        let warnings = ["Warning 1", "Warning 2"]
        let result3 = ValidationResult(warnings: warnings)
        XCTAssertTrue(result3.isValid)
        XCTAssertTrue(result3.hasWarnings)
        XCTAssertEqual(result3.warnings.count, 2)
        XCTAssertEqual(result3.primaryWarning, "Warning 1")
        
        // Test with both errors and warnings
        let result4 = ValidationResult(errors: errors, warnings: warnings)
        XCTAssertFalse(result4.isValid)
        XCTAssertTrue(result4.hasWarnings)
        XCTAssertEqual(result4.errors.count, 2)
        XCTAssertEqual(result4.warnings.count, 2)
    }
    
    // MARK: - ProfileValidator Tests
    
    func testValidateValidChildProfile() {
        // Given
        let validProfile = UserProfile(
            babyName: "Test Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .female,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
            interests: ["Animals", "Music"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .toddler
        )
        
        // When
        let result = ProfileValidator.validate(validProfile)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }
    
    func testValidateValidPregnancyProfile() {
        // Given
        let validProfile = UserProfile(
            babyName: "Future Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .notSpecified,
            dueDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
            interests: ["Classical Music", "Nature"],
            favoriteTheme: "gentle",
            preferredStoryTime: Date(),
            babyStage: .pregnancy
        )
        
        // When
        let result = ProfileValidator.validate(validProfile)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }
    
    func testValidateInvalidName() {
        // Test empty name
        let emptyNameProfile = UserProfile(
            babyName: "",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .male,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
            interests: ["Animals"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .infant
        )
        
        let result1 = ProfileValidator.validate(emptyNameProfile)
        XCTAssertFalse(result1.isValid)
        XCTAssertTrue(result1.errors.contains(.invalidName))
        
        // Test name too long
        let longName = String(repeating: "a", count: 51)
        let longNameProfile = UserProfile(
            babyName: longName,
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .male,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
            interests: ["Animals"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .infant
        )
        
        let result2 = ProfileValidator.validate(longNameProfile)
        XCTAssertFalse(result2.isValid)
        XCTAssertTrue(result2.errors.contains(.invalidName))
    }
    
    func testValidateInvalidDateOfBirth() {
        // Test future date of birth
        let futureDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let futureBirthProfile = UserProfile(
            babyName: "Test Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .female,
            dateOfBirth: futureDate,
            interests: ["Animals"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .infant
        )
        
        let result = ProfileValidator.validate(futureBirthProfile)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.invalidDate))
    }
    
    func testValidateInvalidDueDate() {
        // Test due date too far in past
        let pastDate = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        let pastDueDateProfile = UserProfile(
            babyName: "Future Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .notSpecified,
            dueDate: pastDate,
            interests: ["Classical Music"],
            favoriteTheme: "gentle",
            preferredStoryTime: Date(),
            babyStage: .pregnancy
        )
        
        let result = ProfileValidator.validate(pastDueDateProfile)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.invalidDate))
    }
    
    func testValidateIncompletePregnancyProfile() {
        // Test pregnancy profile without due date
        let incompleteProfile = UserProfile(
            babyName: "Future Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .notSpecified,
            dueDate: nil,
            interests: ["Classical Music"],
            favoriteTheme: "gentle",
            preferredStoryTime: Date(),
            babyStage: .pregnancy
        )
        
        let result = ProfileValidator.validate(incompleteProfile)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.profileIncomplete))
    }
    
    func testValidateIncompleteChildProfile() {
        // Test child profile without date of birth
        let incompleteProfile = UserProfile(
            babyName: "Test Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .male,
            dateOfBirth: nil,
            interests: ["Animals"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .toddler
        )
        
        let result = ProfileValidator.validate(incompleteProfile)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.profileIncomplete))
    }
    
    func testValidateStoryTime() {
        // Test valid story time
        let validTime = Calendar.current.date(from: DateComponents(hour: 19, minute: 30))!
        let validProfile = UserProfile(
            babyName: "Test Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .male,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
            interests: ["Animals"],
            favoriteTheme: "adventure",
            preferredStoryTime: validTime,
            babyStage: .toddler
        )
        
        let result = ProfileValidator.validate(validProfile)
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateInterests() {
        // Test too many interests
        let manyInterests = Array(repeating: "Interest", count: 11)
        let manyInterestsProfile = UserProfile(
            babyName: "Test Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .male,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
            interests: manyInterests,
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .toddler
        )
        
        let result = ProfileValidator.validate(manyInterestsProfile)
        // Should be valid but have warnings
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.hasWarnings)
    }
    
    func testValidateEmptyParentNames() {
        // Test pregnancy profile with empty parent names
        let emptyParentNamesProfile = UserProfile(
            babyName: "Future Baby",
            parentNames: ParentNames(motherName: "", fatherName: ""),
            gender: .notSpecified,
            dueDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
            interests: ["Classical Music"],
            favoriteTheme: "gentle",
            preferredStoryTime: Date(),
            babyStage: .pregnancy
        )
        
        let result = ProfileValidator.validate(emptyParentNamesProfile)
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.profileIncomplete))
    }
    
    func testValidateChildAgeTooOld() {
        // Test child too old
        let oldDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())!
        let oldChildProfile = UserProfile(
            babyName: "Old Child",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .male,
            dateOfBirth: oldDate,
            interests: ["Animals"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .preschooler
        )
        
        let result = ProfileValidator.validate(oldChildProfile)
        // Should be valid but have warnings
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.hasWarnings)
    }
    
    func testValidateDueDateFarFuture() {
        // Test due date very far in future
        let farFutureDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        let farFutureDueDateProfile = UserProfile(
            babyName: "Future Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .notSpecified,
            dueDate: farFutureDate,
            interests: ["Classical Music"],
            favoriteTheme: "gentle",
            preferredStoryTime: Date(),
            babyStage: .pregnancy
        )
        
        let result = ProfileValidator.validate(farFutureDueDateProfile)
        // Should be valid but have warnings
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.hasWarnings)
    }
}
