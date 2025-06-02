//
//  MockStoryGenerationServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct MockStoryGenerationServiceTests {
    
    @Test("MockStoryGenerationService initialization")
    func testInitialization() {
        // Test default initialization
        let service = MockStoryGenerationService()
        #expect(service != nil)
        
        // Test initialization with custom delay
        let customService = MockStoryGenerationService(mockDelay: 1.0)
        #expect(customService != nil)
    }
    
    @Test("MockStoryGenerationService generateStory with valid inputs")
    func testGenerateStoryWithValidInputs() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: ["Animals", "Adventure"]
        )
        
        let options = StoryOptions(
            length: .medium,
            theme: "Adventure",
            characters: ["Teddy Bear"]
        )
        
        let story = try await service.generateStory(for: profile, with: options)
        
        #expect(!story.title.isEmpty)
        #expect(!story.content.isEmpty)
        #expect(story.theme == "Adventure")
        #expect(story.length == .medium)
        #expect(story.characters == ["Teddy Bear"])
        #expect(story.ageRange == .toddler)
        #expect(story.readingTime > 0)
        #expect(!story.tags.isEmpty)
        #expect(story.title.contains(profile.displayName))
    }
    
    @Test("MockStoryGenerationService generateStory with invalid profile")
    func testGenerateStoryWithInvalidProfile() async {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let invalidProfile = UserProfile(
            name: "",  // Empty name should make profile invalid
            babyStage: .infant,
            dateOfBirth: Date(),
            gender: .notSpecified,
            interests: []
        )
        
        let options = StoryOptions(
            length: .short,
            theme: "Adventure",
            characters: []
        )
        
        do {
            let _ = try await service.generateStory(for: invalidProfile, with: options)
            #expect(Bool(false), "Should have thrown an error for invalid profile")
        } catch StoryGenerationError.invalidProfile {
            #expect(true)
        } catch {
            #expect(Bool(false), "Should have thrown invalidProfile error")
        }
    }
    
    @Test("MockStoryGenerationService generateStory with invalid options")
    func testGenerateStoryWithInvalidOptions() async {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            dateOfBirth: Date(),
            gender: .girl,
            interests: ["Music"]
        )
        
        let invalidOptions = StoryOptions(
            length: .short,
            theme: "",  // Empty theme should make options invalid
            characters: []
        )
        
        do {
            let _ = try await service.generateStory(for: profile, with: invalidOptions)
            #expect(Bool(false), "Should have thrown an error for invalid options")
        } catch StoryGenerationError.invalidProfile {
            #expect(true)
        } catch {
            #expect(Bool(false), "Should have thrown invalidProfile error")
        }
    }
    
    @Test("MockStoryGenerationService generateDailyStory")
    func testGenerateDailyStory() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Daily Story Baby",
            babyStage: .preschooler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .girl,
            interests: ["Learning", "Colors"]
        )
        
        let story = try await service.generateDailyStory(for: profile)
        
        #expect(!story.title.isEmpty)
        #expect(!story.content.isEmpty)
        #expect(story.length == .medium)
        #expect(!story.theme.isEmpty)
        #expect(story.ageRange == .preschooler)
        #expect(story.title.contains(profile.displayName))
    }
    
    @Test("MockStoryGenerationService canGenerateStory validation")
    func testCanGenerateStoryValidation() {
        let service = MockStoryGenerationService()
        
        // Valid profile and options
        let validProfile = UserProfile(
            name: "Valid Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: ["Animals"]
        )
        
        let validOptions = StoryOptions(
            length: .medium,
            theme: "Adventure",
            characters: []
        )
        
        #expect(service.canGenerateStory(for: validProfile, with: validOptions) == true)
        
        // Invalid profile (empty name)
        let invalidProfile = UserProfile(
            name: "   ",  // Whitespace only
            babyStage: .infant,
            dateOfBirth: Date(),
            gender: .notSpecified,
            interests: []
        )
        
        #expect(service.canGenerateStory(for: invalidProfile, with: validOptions) == false)
        
        // Invalid options (empty theme)
        let invalidOptions = StoryOptions(
            length: .short,
            theme: "",
            characters: []
        )
        
        #expect(service.canGenerateStory(for: validProfile, with: invalidOptions) == false)
    }
    
    @Test("MockStoryGenerationService getSuggestedThemes")
    func testGetSuggestedThemes() {
        let service = MockStoryGenerationService()
        
        let profile = UserProfile(
            name: "Theme Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .girl,
            interests: ["Animals", "Music", "Colors"]
        )
        
        let themes = service.getSuggestedThemes(for: profile)
        
        #expect(!themes.isEmpty)
        #expect(themes.contains("Adventure"))
        #expect(themes.contains("Friendship"))
        #expect(themes.contains("Magic"))
        #expect(themes.contains("Animals"))
        #expect(themes.contains("Learning"))
        
        // Should include interest-based themes
        #expect(themes.contains("Safari Adventure"))
        #expect(themes.contains("Pet Friends"))
        #expect(themes.contains("Musical Journey"))
        #expect(themes.contains("Rainbow Magic"))
    }
    
    @Test("MockStoryGenerationService getSuggestedThemes without interests")
    func testGetSuggestedThemesWithoutInterests() {
        let service = MockStoryGenerationService()
        
        let profile = UserProfile(
            name: "No Interests Baby",
            babyStage: .infant,
            dateOfBirth: Date(),
            gender: .notSpecified,
            interests: []
        )
        
        let themes = service.getSuggestedThemes(for: profile)
        
        #expect(!themes.isEmpty)
        #expect(themes.contains("Adventure"))
        #expect(themes.contains("Friendship"))
        #expect(themes.contains("Magic"))
        #expect(themes.contains("Animals"))
        #expect(themes.contains("Learning"))
        
        // Should not contain interest-specific themes
        #expect(!themes.contains("Safari Adventure"))
        #expect(!themes.contains("Musical Journey"))
        #expect(!themes.contains("Rainbow Magic"))
    }
    
    @Test("MockStoryGenerationService getEstimatedGenerationTime")
    func testGetEstimatedGenerationTime() {
        let service = MockStoryGenerationService()
        
        let shortOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        let mediumOptions = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        let longOptions = StoryOptions(length: .long, theme: "Adventure", characters: [])
        
        let shortTime = service.getEstimatedGenerationTime(for: shortOptions)
        let mediumTime = service.getEstimatedGenerationTime(for: mediumOptions)
        let longTime = service.getEstimatedGenerationTime(for: longOptions)
        
        #expect(shortTime == 1.5)
        #expect(mediumTime == 2.0)
        #expect(longTime == 3.0)
        
        // Times should be in ascending order
        #expect(shortTime < mediumTime)
        #expect(mediumTime < longTime)
    }
    
    @Test("MockStoryGenerationService story content varies by theme")
    func testStoryContentVariesByTheme() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Theme Test",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: ["Adventure"]
        )
        
        let adventureOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        let friendshipOptions = StoryOptions(length: .short, theme: "Friendship", characters: [])
        let magicOptions = StoryOptions(length: .short, theme: "Magic", characters: [])
        
        let adventureStory = try await service.generateStory(for: profile, with: adventureOptions)
        let friendshipStory = try await service.generateStory(for: profile, with: friendshipOptions)
        let magicStory = try await service.generateStory(for: profile, with: magicOptions)
        
        // Stories should have different themes
        #expect(adventureStory.theme == "Adventure")
        #expect(friendshipStory.theme == "Friendship")
        #expect(magicStory.theme == "Magic")
        
        // Content should be different (at least titles should vary)
        #expect(adventureStory.title != friendshipStory.title)
        #expect(friendshipStory.title != magicStory.title)
        #expect(adventureStory.title != magicStory.title)
    }
    
    @Test("MockStoryGenerationService story length affects content")
    func testStoryLengthAffectsContent() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Length Test",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .girl,
            interests: ["Adventure"]
        )
        
        let shortOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        let mediumOptions = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        let longOptions = StoryOptions(length: .long, theme: "Adventure", characters: [])
        
        let shortStory = try await service.generateStory(for: profile, with: shortOptions)
        let mediumStory = try await service.generateStory(for: profile, with: mediumOptions)
        let longStory = try await service.generateStory(for: profile, with: longOptions)
        
        // Longer stories should generally have more content
        #expect(shortStory.content.count <= mediumStory.content.count)
        #expect(mediumStory.content.count <= longStory.content.count)
        
        // All should have the same theme
        #expect(shortStory.theme == "Adventure")
        #expect(mediumStory.theme == "Adventure")
        #expect(longStory.theme == "Adventure")
    }
    
    @Test("MockStoryGenerationService character integration")
    func testCharacterIntegration() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Character Test",
            babyStage: .preschooler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .boy,
            interests: ["Friendship"]
        )
        
        let options = StoryOptions(
            length: .medium,
            theme: "Friendship",
            characters: ["Teddy Bear", "Magic Dragon"]
        )
        
        let story = try await service.generateStory(for: profile, with: options)
        
        #expect(story.characters == ["Teddy Bear", "Magic Dragon"])
        #expect(!story.tags.isEmpty)
        #expect(story.tags.contains("Teddy Bear"))
        #expect(story.tags.contains("Magic Dragon"))
    }
    
    @Test("MockStoryGenerationService age-appropriate content")
    func testAgeAppropriateContent() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        // Test different age stages
        let pregnancyProfile = UserProfile(name: "Pregnancy", babyStage: .pregnancy, dueDate: Date(), gender: .notSpecified, interests: [])
        let newbornProfile = UserProfile(name: "Newborn", babyStage: .newborn, dateOfBirth: Date(), gender: .boy, interests: [])
        let infantProfile = UserProfile(name: "Infant", babyStage: .infant, dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()), gender: .girl, interests: [])
        let toddlerProfile = UserProfile(name: "Toddler", babyStage: .toddler, dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()), gender: .boy, interests: [])
        let preschoolerProfile = UserProfile(name: "Preschooler", babyStage: .preschooler, dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()), gender: .girl, interests: [])
        
        let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        let pregnancyStory = try await service.generateStory(for: pregnancyProfile, with: options)
        let newbornStory = try await service.generateStory(for: newbornProfile, with: options)
        let infantStory = try await service.generateStory(for: infantProfile, with: options)
        let toddlerStory = try await service.generateStory(for: toddlerProfile, with: options)
        let preschoolerStory = try await service.generateStory(for: preschoolerProfile, with: options)
        
        // All stories should be generated successfully
        #expect(!pregnancyStory.content.isEmpty)
        #expect(!newbornStory.content.isEmpty)
        #expect(!infantStory.content.isEmpty)
        #expect(!toddlerStory.content.isEmpty)
        #expect(!preschoolerStory.content.isEmpty)
        
        // Age ranges should match
        #expect(pregnancyStory.ageRange == .pregnancy)
        #expect(newbornStory.ageRange == .newborn)
        #expect(infantStory.ageRange == .infant)
        #expect(toddlerStory.ageRange == .toddler)
        #expect(preschoolerStory.ageRange == .preschooler)
    }
    
    @Test("MockStoryGenerationService reading time estimation")
    func testReadingTimeEstimation() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Reading Time Test",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: ["Stories"]
        )
        
        let shortOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        let longOptions = StoryOptions(length: .long, theme: "Adventure", characters: [])
        
        let shortStory = try await service.generateStory(for: profile, with: shortOptions)
        let longStory = try await service.generateStory(for: profile, with: longOptions)
        
        // Reading time should be positive
        #expect(shortStory.readingTime > 0)
        #expect(longStory.readingTime > 0)
        
        // Longer stories should generally have longer reading times
        #expect(longStory.readingTime >= shortStory.readingTime)
    }
    
    @Test("MockStoryGenerationService tag generation")
    func testTagGeneration() async throws {
        let service = MockStoryGenerationService(mockDelay: 0.1)
        
        let profile = UserProfile(
            name: "Tag Test",
            babyStage: .preschooler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .girl,
            interests: ["Animals", "Music", "Colors", "Adventure", "Learning"]
        )
        
        let options = StoryOptions(
            length: .medium,
            theme: "Adventure",
            characters: ["Bunny", "Bird"]
        )
        
        let story = try await service.generateStory(for: profile, with: options)
        
        #expect(!story.tags.isEmpty)
        #expect(story.tags.contains("Adventure"))
        #expect(story.tags.contains("preschooler"))
        
        // Should contain some interests (limited to first 2)
        let interestTags = story.tags.filter { profile.interests.contains($0) }
        #expect(interestTags.count <= 2)
        
        // Should contain some characters (limited to first 2)
        let characterTags = story.tags.filter { options.characters.contains($0) }
        #expect(characterTags.count <= 2)
    }
}
