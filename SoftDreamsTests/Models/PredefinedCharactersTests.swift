//
//  PredefinedCharactersTests.swift
//  SoftDreamsTests
//
//  Created by Copilot on 6/5/25.
//

import Testing
@testable import SoftDreams

@Test("PredefinedCharacters should contain exactly 10 characters")
func testPredefinedCharactersCount() {
    let characters = PredefinedCharacters.allCharacters
    #expect(characters.count == 10)
}

@Test("PredefinedCharacters should have all unique characters")
func testPredefinedCharactersUniqueness() {
    let characters = PredefinedCharacters.allCharacters
    let uniqueCharacters = Set(characters.map { $0.name })
    #expect(uniqueCharacters.count == characters.count)
}

@Test("PredefinedCharacters should return random characters")
func testGetRandomCharacters() {
    // Test getting 1-3 random characters
    for count in 1...3 {
        let randomCharacters = PredefinedCharacters.getRandomCharacters(count: count)
        #expect(randomCharacters.count == count)
        #expect(randomCharacters.allSatisfy { character in
            PredefinedCharacters.allCharacters.contains { $0.name == character }
        })
    }
}

@Test("PredefinedCharacters should handle edge cases for random selection")
func testGetRandomCharactersEdgeCases() {
    // Test count 0
    let zeroCharacters = PredefinedCharacters.getRandomCharacters(count: 0)
    #expect(zeroCharacters.isEmpty)
    
    // Test count greater than available characters
    let tooManyCharacters = PredefinedCharacters.getRandomCharacters(count: 15)
    #expect(tooManyCharacters.count <= PredefinedCharacters.allCharacters.count)
    
    // Test negative count
    let negativeCount = PredefinedCharacters.getRandomCharacters(count: -1)
    #expect(negativeCount.isEmpty)
}

@Test("PredefinedCharacters should return age-appropriate characters")
func testGetAgeAppropriateCharacters() {
    // Test for pregnancy stage
    let pregnancyCharacters = PredefinedCharacters.getAgeAppropriateCharacters(for: .pregnancy, count: 2)
    #expect(pregnancyCharacters.count <= 2)
    #expect(pregnancyCharacters.allSatisfy { character in
        let predefinedCharacter = PredefinedCharacters.allCharacters.first { $0.name == character }
        return predefinedCharacter?.appropriateAges.contains(.pregnancy) ?? false
    })
    
    // Test for toddler stage
    let toddlerCharacters = PredefinedCharacters.getAgeAppropriateCharacters(for: .toddler, count: 3)
    #expect(toddlerCharacters.count <= 3)
    #expect(toddlerCharacters.allSatisfy { character in
        let predefinedCharacter = PredefinedCharacters.allCharacters.first { $0.name == character }
        return predefinedCharacter?.appropriateAges.contains(.toddler) ?? false
    })
    
    // Test for preschooler stage
    let preschoolerCharacters = PredefinedCharacters.getAgeAppropriateCharacters(for: .preschooler, count: 2)
    #expect(preschoolerCharacters.count <= 2)
    #expect(preschoolerCharacters.allSatisfy { character in
        let predefinedCharacter = PredefinedCharacters.allCharacters.first { $0.name == character }
        return predefinedCharacter?.appropriateAges.contains(.preschooler) ?? false
    })
}

@Test("PredefinedCharacters should have characters appropriate for all age stages")
func testCharactersForAllAges() {
    for ageStage in BabyStage.allCases {
        let appropriateCharacters = PredefinedCharacters.allCharacters.filter { character in
            character.appropriateAges.contains(ageStage)
        }
        #expect(appropriateCharacters.count >= 3, "Should have at least 3 characters for \(ageStage)")
    }
}

@Test("StoryOptions should use predefined characters when empty")
func testStoryOptionsWithPredefinedCharacters() {
    var options = StoryOptions(characters: [])
    let profile = UserProfile(name: "Test Child", babyStage: .toddler)
    
    // Test applying predefined characters
    options.applyPredefinedCharactersIfNeeded(for: profile)
    
    #expect(!options.characters.isEmpty)
    #expect(options.characters.count <= 3) // Should add 1-3 characters
    #expect(options.characters.allSatisfy { character in
        PredefinedCharacters.allCharacters.contains { $0.name == character }
    })
}

@Test("StoryOptions should not override existing characters")
func testStoryOptionsPreservesExistingCharacters() {
    let existingCharacters = ["Custom Dragon", "Magic Unicorn"]
    var options = StoryOptions(characters: existingCharacters)
    let profile = UserProfile(name: "Test Child", babyStage: .toddler)
    
    // Test that existing characters are preserved
    options.applyPredefinedCharactersIfNeeded(for: profile)
    
    #expect(options.characters == existingCharacters)
}
