//
//  StoryTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct StoryTests {
    
    // MARK: - Initialization Tests
    
    @Test("Test Story initialization with all parameters")
    func testStoryInitializationWithAllParameters() async throws {
        // Given
        let id = UUID()
        let title = "Test Story"
        let content = "This is a test story with multiple words for word count testing."
        let date = Date()
        let theme = "Adventure"
        let length = StoryLength.medium
        let characters = ["Hero", "Villain"]
        let ageRange = BabyStage.toddler
        let readingTime: TimeInterval = 300 // 5 minutes
        let tags = ["adventure", "hero"]
        
        // When
        let story = Story(
            id: id,
            title: title,
            content: content,
            date: date,
            isFavorite: true,
            theme: theme,
            length: length,
            characters: characters,
            ageRange: ageRange,
            readingTime: readingTime,
            tags: tags
        )
        
        // Then
        #expect(story.id == id)
        #expect(story.title == title)
        #expect(story.content == content)
        #expect(story.date == date)
        #expect(story.isFavorite == true)
        #expect(story.theme == theme)
        #expect(story.length == length)
        #expect(story.characters == characters)
        #expect(story.ageRange == ageRange)
        #expect(story.readingTime == readingTime)
        #expect(story.tags == tags)
    }
    
    @Test("Test Story initialization with default parameters")
    func testStoryInitializationWithDefaults() async throws {
        // Given
        let title = "Test Story"
        let content = "Test content"
        let theme = "Adventure"
        let length = StoryLength.short
        let ageRange = BabyStage.toddler
        
        // When
        let story = Story(
            title: title,
            content: content,
            theme: theme,
            length: length,
            ageRange: ageRange
        )
        
        // Then
        #expect(story.title == title)
        #expect(story.content == content)
        #expect(story.isFavorite == false)
        #expect(story.theme == theme)
        #expect(story.length == length)
        #expect(story.characters.isEmpty)
        #expect(story.ageRange == ageRange)
        #expect(story.readingTime == nil)
        #expect(story.tags.isEmpty)
    }
    
    // MARK: - Computed Properties Tests
    
    @Test("Test formattedDate property")
    func testFormattedDate() async throws {
        // Given
        let dateComponents = DateComponents(year: 2025, month: 6, day: 2)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let story = Story(
            title: "Test",
            content: "Content",
            date: date,
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When
        let formattedDate = story.formattedDate
        
        // Then
        #expect(formattedDate.contains("2025"))
        #expect(formattedDate.contains("Jun") || formattedDate.contains("6"))
        #expect(formattedDate.contains("2"))
    }
    
    @Test("Test estimatedReadingTimeMinutes with provided reading time")
    func testEstimatedReadingTimeMinutesWithProvidedTime() async throws {
        // Given
        let story = Story(
            title: "Test",
            content: "Content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler,
            readingTime: 300 // 5 minutes
        )
        
        // When
        let estimatedTime = story.estimatedReadingTimeMinutes
        
        // Then
        #expect(estimatedTime == 5)
    }
    
    @Test("Test estimatedReadingTimeMinutes with fallback calculation")
    func testEstimatedReadingTimeMinutesWithFallback() async throws {
        // Given
        let longContent = String(repeating: "word ", count: 300) // 300 words
        let story = Story(
            title: "Test",
            content: longContent,
            theme: "Adventure",
            length: .long,
            ageRange: .toddler
        )
        
        // When
        let estimatedTime = story.estimatedReadingTimeMinutes
        
        // Then
        #expect(estimatedTime == 2) // 300 words / 150 wpm = 2 minutes
    }
    
    @Test("Test estimatedReadingTimeMinutes minimum value")
    func testEstimatedReadingTimeMinutesMinimum() async throws {
        // Given
        let story = Story(
            title: "Test",
            content: "Short",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler,
            readingTime: 30 // 30 seconds
        )
        
        // When
        let estimatedTime = story.estimatedReadingTimeMinutes
        
        // Then
        #expect(estimatedTime == 1) // Minimum 1 minute
    }
    
    @Test("Test wordCount property")
    func testWordCount() async throws {
        // Given
        let content = "This is a test story with ten words exactly here."
        let story = Story(
            title: "Test",
            content: content,
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When
        let wordCount = story.wordCount
        
        // Then
        #expect(wordCount == 11) // "This is a test story with ten words exactly here."
    }
    
    @Test("Test wordCount with empty content")
    func testWordCountWithEmptyContent() async throws {
        // Given
        let story = Story(
            title: "Test",
            content: "",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When
        let wordCount = story.wordCount
        
        // Then
        #expect(wordCount == 0)
    }
    
    @Test("Test wordCount with whitespace only")
    func testWordCountWithWhitespaceOnly() async throws {
        // Given
        let story = Story(
            title: "Test",
            content: "   \n\t  ",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When
        let wordCount = story.wordCount
        
        // Then
        #expect(wordCount == 0)
    }
    
    // MARK: - Codable Tests
    
    @Test("Test Story encoding and decoding")
    func testStoryEncodingAndDecoding() async throws {
        // Given
        let originalStory = Story(
            title: "Test Story",
            content: "Test content",
            isFavorite: true,
            theme: "Adventure",
            length: .medium,
            characters: ["Hero"],
            ageRange: .toddler,
            readingTime: 300,
            tags: ["test"]
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalStory)
        
        let decoder = JSONDecoder()
        let decodedStory = try decoder.decode(Story.self, from: data)
        
        // Then
        #expect(decodedStory == originalStory)
    }
    
    // MARK: - Equatable Tests
    
    @Test("Test Story equality")
    func testStoryEquality() async throws {
        // Given
        let id = UUID()
        let story1 = Story(
            id: id,
            title: "Test",
            content: "Content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let story2 = Story(
            id: id,
            title: "Test",
            content: "Content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When & Then
        #expect(story1 == story2)
    }
    
    @Test("Test Story inequality")
    func testStoryInequality() async throws {
        // Given
        let story1 = Story(
            title: "Test 1",
            content: "Content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let story2 = Story(
            title: "Test 2",
            content: "Content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When & Then
        #expect(story1 != story2)
    }
}
