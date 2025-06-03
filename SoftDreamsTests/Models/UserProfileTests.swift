//
//  UserProfileTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct UserProfileTests {
    
    // MARK: - BabyStage Tests
    
    @Test("Test BabyStage case values")
    func testBabyStageValues() async throws {
        #expect(BabyStage.pregnancy.rawValue == "pregnancy")
        #expect(BabyStage.newborn.rawValue == "newborn")
        #expect(BabyStage.infant.rawValue == "infant")
        #expect(BabyStage.toddler.rawValue == "toddler")
        #expect(BabyStage.preschooler.rawValue == "preschooler")
    }
    
    @Test("Test BabyStage allCases")
    func testBabyStageAllCases() async throws {
        let allCases = BabyStage.allCases
        #expect(allCases.count == 5)
        #expect(allCases.contains(.pregnancy))
        #expect(allCases.contains(.newborn))
        #expect(allCases.contains(.infant))
        #expect(allCases.contains(.toddler))
        #expect(allCases.contains(.preschooler))
    }
    
    @Test("Test BabyStage displayName")
    func testBabyStageDisplayName() async throws {
        // Test that display names are not empty and are localized
        #expect(!BabyStage.pregnancy.displayName.isEmpty)
        #expect(!BabyStage.newborn.displayName.isEmpty)
        #expect(!BabyStage.infant.displayName.isEmpty)
        #expect(!BabyStage.toddler.displayName.isEmpty)
        #expect(!BabyStage.preschooler.displayName.isEmpty)
    }
    
    @Test("Test BabyStage description")
    func testBabyStageDescription() async throws {
        // Test that descriptions are not empty and are localized
        #expect(!BabyStage.pregnancy.description.isEmpty)
        #expect(!BabyStage.newborn.description.isEmpty)
        #expect(!BabyStage.infant.description.isEmpty)
        #expect(!BabyStage.toddler.description.isEmpty)
        #expect(!BabyStage.preschooler.description.isEmpty)
    }
    
    @Test("Test BabyStage codable")
    func testBabyStageCodeable() async throws {
        // Given
        let originalStage = BabyStage.toddler
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalStage)
        
        let decoder = JSONDecoder()
        let decodedStage = try decoder.decode(BabyStage.self, from: data)
        
        // Then
        #expect(decodedStage == originalStage)
    }
    
    // MARK: - Gender Tests
    
    @Test("Test Gender case values")
    func testGenderValues() async throws {
        #expect(Gender.male.rawValue == "male")
        #expect(Gender.female.rawValue == "female")
        #expect(Gender.notSpecified.rawValue == "not_specified")
    }
    
    @Test("Test Gender allCases")
    func testGenderAllCases() async throws {
        let allCases = Gender.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.male))
        #expect(allCases.contains(.female))
        #expect(allCases.contains(.notSpecified))
    }
    
    @Test("Test Gender displayName")
    func testGenderDisplayName() async throws {
        #expect(!Gender.male.displayName.isEmpty)
        #expect(!Gender.female.displayName.isEmpty)
        #expect(!Gender.notSpecified.displayName.isEmpty)
    }
    
    @Test("Test Gender pronoun")
    func testGenderPronoun() async throws {
        #expect(!Gender.male.pronoun.isEmpty)
        #expect(!Gender.female.pronoun.isEmpty)
        #expect(!Gender.notSpecified.pronoun.isEmpty)
    }
    
    @Test("Test Gender possessivePronoun")
    func testGenderPossessivePronoun() async throws {
        #expect(!Gender.male.possessivePronoun.isEmpty)
        #expect(!Gender.female.possessivePronoun.isEmpty)
        #expect(!Gender.notSpecified.possessivePronoun.isEmpty)
    }
    
    @Test("Test Gender codable")
    func testGenderCodeable() async throws {
        // Given
        let originalGender = Gender.female
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalGender)
        
        let decoder = JSONDecoder()
        let decodedGender = try decoder.decode(Gender.self, from: data)
        
        // Then
        #expect(decodedGender == originalGender)
    }
    
    // MARK: - UserProfile Tests
    
    @Test("Test UserProfile initialization")
    func testUserProfileInitialization() async throws {
        // Given
        let name = "Test Baby"
        let babyStage = BabyStage.toddler
        let interests = ["animals", "music"]
        let storyTime = Date()
        let dueDate = Date()
        let parentNames = ["Mom", "Dad"]
        let dateOfBirth = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        let lastUpdate = Date()
        let gender = Gender.female
        let language = Language.english
        
        // When
        let profile = UserProfile(
            name: name,
            babyStage: babyStage,
            interests: interests,
            storyTime: storyTime,
            dueDate: dueDate,
            parentNames: parentNames,
            dateOfBirth: dateOfBirth,
            lastUpdate: lastUpdate,
            gender: gender,
            language: language
        )
        
        // Then
        #expect(profile.name == name)
        #expect(profile.babyStage == babyStage)
        #expect(profile.interests == interests)
        #expect(profile.storyTime == storyTime)
        #expect(profile.dueDate == dueDate)
        #expect(profile.parentNames == parentNames)
        #expect(profile.dateOfBirth == dateOfBirth)
        #expect(profile.lastUpdate == lastUpdate)
        #expect(profile.gender == gender)
        #expect(profile.language == language)
    }
    
    @Test("Test UserProfile isPregnancy computed property")
    func testUserProfileIsPregnancy() async throws {
        // Given
        let pregnancyProfile = UserProfile(
            name: "Test",
            babyStage: .pregnancy,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        let toddlerProfile = UserProfile(
            name: "Test",
            babyStage: .toddler,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When & Then
        #expect(pregnancyProfile.isPregnancy == true)
        #expect(toddlerProfile.isPregnancy == false)
    }
    
    @Test("Test UserProfile currentAge calculation")
    func testUserProfileCurrentAge() async throws {
        // Given
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .month, value: -18, to: Date())! // 18 months ago
        
        let profile = UserProfile(
            name: "Test",
            babyStage: .toddler,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            dateOfBirth: dateOfBirth,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When
        let currentAge = profile.currentAge
        
        // Then
        #expect(currentAge == 18)
    }
    
    @Test("Test UserProfile currentAge with nil dateOfBirth")
    func testUserProfileCurrentAgeWithNilDateOfBirth() async throws {
        // Given
        let profile = UserProfile(
            name: "Test",
            babyStage: .pregnancy,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            dateOfBirth: nil,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When
        let currentAge = profile.currentAge
        
        // Then
        #expect(currentAge == nil)
    }
    
    @Test("Test UserProfile currentAgeInYears calculation")
    func testUserProfileCurrentAgeInYears() async throws {
        // Given
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .year, value: -3, to: Date())! // 3 years ago
        
        let profile = UserProfile(
            name: "Test",
            babyStage: .preschooler,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            dateOfBirth: dateOfBirth,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When
        let currentAgeInYears = profile.currentAgeInYears
        
        // Then
        #expect(currentAgeInYears == 3)
    }
    
    @Test("Test UserProfile ageDisplayString for months")
    func testUserProfileAgeDisplayStringForMonths() async throws {
        // Given
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .month, value: -8, to: Date())! // 8 months ago
        
        let profile = UserProfile(
            name: "Test",
            babyStage: .infant,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            dateOfBirth: dateOfBirth,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When
        let ageDisplay = profile.ageDisplayString
        
        // Then
        #expect(ageDisplay != nil)
        #expect(ageDisplay!.contains("8"))
    }
    
    @Test("Test UserProfile ageDisplayString for years")
    func testUserProfileAgeDisplayStringForYears() async throws {
        // Given
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .year, value: -2, to: Date())! // 2 years ago
        
        let profile = UserProfile(
            name: "Test",
            babyStage: .toddler,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            dateOfBirth: dateOfBirth,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When
        let ageDisplay = profile.ageDisplayString
        
        // Then
        #expect(ageDisplay != nil)
        #expect(ageDisplay!.contains("2"))
    }
    
    @Test("Test UserProfile ageDisplayString with nil dateOfBirth")
    func testUserProfileAgeDisplayStringWithNilDateOfBirth() async throws {
        // Given
        let profile = UserProfile(
            name: "Test",
            babyStage: .pregnancy,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            dateOfBirth: nil,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When
        let ageDisplay = profile.ageDisplayString
        
        // Then
        #expect(ageDisplay == nil)
    }
    
    @Test("Test UserProfile codable")
    func testUserProfileCodeable() async throws {
        // Given
        let originalProfile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["animals", "music"],
            storyTime: Date(),
            dueDate: Date(),
            parentNames: ["Mom", "Dad"],
            dateOfBirth: Date(),
            lastUpdate: Date(),
            gender: .female,
            language: .english
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalProfile)
        
        let decoder = JSONDecoder()
        let decodedProfile = try decoder.decode(UserProfile.self, from: data)
        
        // Then
        #expect(decodedProfile == originalProfile)
    }
    
    @Test("Test UserProfile equatable")
    func testUserProfileEquatable() async throws {
        // Given
        let profile1 = UserProfile(
            name: "Test",
            babyStage: .toddler,
            interests: ["animals"],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        let profile2 = UserProfile(
            name: "Test",
            babyStage: .toddler,
            interests: ["animals"],
            storyTime: profile1.storyTime,
            parentNames: [],
            lastUpdate: profile1.lastUpdate,
            gender: .notSpecified,
            language: .english
        )
        
        // When & Then
        #expect(profile1 == profile2)
    }
    
    @Test("Test UserProfile inequality")
    func testUserProfileInequality() async throws {
        // Given
        let profile1 = UserProfile(
            name: "Test 1",
            babyStage: .toddler,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        let profile2 = UserProfile(
            name: "Test 2",
            babyStage: .toddler,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        
        // When & Then
        #expect(profile1 != profile2)
    }
}
