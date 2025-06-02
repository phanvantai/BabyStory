//
//  StoryOptionsTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct StoryOptionsTests {
    
    // MARK: - StoryLength Tests
    
    @Test("Test StoryLength case values")
    func testStoryLengthCaseValues() async throws {
        #expect(StoryLength.short.rawValue == "short")
        #expect(StoryLength.medium.rawValue == "medium")
        #expect(StoryLength.long.rawValue == "long")
    }
    
    @Test("Test StoryLength identifiable conformance")
    func testStoryLengthIdentifiable() async throws {
        #expect(StoryLength.short.id == "short")
        #expect(StoryLength.medium.id == "medium")
        #expect(StoryLength.long.id == "long")
    }
    
    @Test("Test StoryLength description localization")
    func testStoryLengthDescription() async throws {
        // Given & When
        let shortDescription = StoryLength.short.description
        let mediumDescription = StoryLength.medium.description
        let longDescription = StoryLength.long.description
        
        // Then
        #expect(!shortDescription.isEmpty)
        #expect(!mediumDescription.isEmpty)
        #expect(!longDescription.isEmpty)
        #expect(shortDescription != mediumDescription)
        #expect(mediumDescription != longDescription)
    }
    
    @Test("Test StoryLength aiPromptDescription")
    func testStoryLengthAIPromptDescription() async throws {
        #expect(StoryLength.short.aiPromptDescription == "Quick tale (2-3 minutes)")
        #expect(StoryLength.medium.aiPromptDescription == "Perfect story (5-7 minutes)")
        #expect(StoryLength.long.aiPromptDescription == "Extended adventure (10+ minutes)")
    }
    
    @Test("Test StoryLength allCases")
    func testStoryLengthAllCases() async throws {
        let allCases = StoryLength.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.short))
        #expect(allCases.contains(.medium))
        #expect(allCases.contains(.long))
    }
    
    @Test("Test StoryLength codable")
    func testStoryLengthCodable() async throws {
        // Given
        let originalLength = StoryLength.medium
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalLength)
        
        let decoder = JSONDecoder()
        let decodedLength = try decoder.decode(StoryLength.self, from: data)
        
        // Then
        #expect(decodedLength == originalLength)
    }
    
    // MARK: - StoryTheme Tests
    
    @Test("Test StoryTheme case values")
    func testStoryThemeCaseValues() async throws {
        #expect(StoryTheme.adventure.rawValue == "Adventure")
        #expect(StoryTheme.friendship.rawValue == "Friendship")
        #expect(StoryTheme.magic.rawValue == "Magic")
        #expect(StoryTheme.animals.rawValue == "Animals")
        #expect(StoryTheme.learning.rawValue == "Learning")
        #expect(StoryTheme.kindness.rawValue == "Kindness")
        #expect(StoryTheme.nature.rawValue == "Nature")
        #expect(StoryTheme.family.rawValue == "Family")
        #expect(StoryTheme.dreams.rawValue == "Dreams")
        #expect(StoryTheme.creativity.rawValue == "Creativity")
    }
    
    @Test("Test StoryTheme identifiable conformance")
    func testStoryThemeIdentifiable() async throws {
        #expect(StoryTheme.adventure.id == "Adventure")
        #expect(StoryTheme.friendship.id == "Friendship")
        #expect(StoryTheme.magic.id == "Magic")
    }
    
    @Test("Test StoryTheme allCases count")
    func testStoryThemeAllCasesCount() async throws {
        let allCases = StoryTheme.allCases
        #expect(allCases.count == 10)
    }
    
    @Test("Test StoryTheme contains all expected cases")
    func testStoryThemeContainsAllExpectedCases() async throws {
        let allCases = StoryTheme.allCases
        #expect(allCases.contains(.adventure))
        #expect(allCases.contains(.friendship))
        #expect(allCases.contains(.magic))
        #expect(allCases.contains(.animals))
        #expect(allCases.contains(.learning))
        #expect(allCases.contains(.kindness))
        #expect(allCases.contains(.nature))
        #expect(allCases.contains(.family))
        #expect(allCases.contains(.dreams))
        #expect(allCases.contains(.creativity))
    }
    
    @Test("Test StoryTheme codable")
    func testStoryThemeCodable() async throws {
        // Given
        let originalTheme = StoryTheme.adventure
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTheme)
        
        let decoder = JSONDecoder()
        let decodedTheme = try decoder.decode(StoryTheme.self, from: data)
        
        // Then
        #expect(decodedTheme == originalTheme)
    }
}

// MARK: - StoryOptions Model Tests

struct StoryOptionsModelTests {
    
    @Test("Test StoryOptions initialization with all parameters")
    func testStoryOptionsInitializationWithAllParameters() async throws {
        // Given
        let length = StoryLength.medium
        let theme = StoryTheme.adventure
        let includeParents = true
        let characters = ["Hero", "Sidekick"]
        let customInstructions = "Make it funny"
        
        // When
        let options = StoryOptions(
            length: length,
            theme: theme,
            includeParents: includeParents,
            characters: characters,
            customInstructions: customInstructions
        )
        
        // Then
        #expect(options.length == length)
        #expect(options.theme == theme)
        #expect(options.includeParents == includeParents)
        #expect(options.characters == characters)
        #expect(options.customInstructions == customInstructions)
    }
    
    @Test("Test StoryOptions initialization with default parameters")
    func testStoryOptionsInitializationWithDefaults() async throws {
        // Given & When
        let options = StoryOptions()
        
        // Then
        #expect(options.length == .medium)
        #expect(options.theme == .adventure)
        #expect(options.includeParents == false)
        #expect(options.characters.isEmpty)
        #expect(options.customInstructions.isEmpty)
    }
    
    @Test("Test StoryOptions codable")
    func testStoryOptionsCodable() async throws {
        // Given
        let originalOptions = StoryOptions(
            length: .long,
            theme: .magic,
            includeParents: true,
            characters: ["Wizard", "Dragon"],
            customInstructions: "Include a castle"
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalOptions)
        
        let decoder = JSONDecoder()
        let decodedOptions = try decoder.decode(StoryOptions.self, from: data)
        
        // Then
        #expect(decodedOptions.length == originalOptions.length)
        #expect(decodedOptions.theme == originalOptions.theme)
        #expect(decodedOptions.includeParents == originalOptions.includeParents)
        #expect(decodedOptions.characters == originalOptions.characters)
        #expect(decodedOptions.customInstructions == originalOptions.customInstructions)
    }
}
