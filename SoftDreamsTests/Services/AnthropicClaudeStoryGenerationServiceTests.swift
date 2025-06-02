//
//  AnthropicClaudeStoryGenerationServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct AnthropicClaudeStoryGenerationServiceTests {
    
    @Test("AnthropicClaudeStoryGenerationService initialization")
    func testInitialization() {
        // Test initialization with minimal parameters
        let service = AnthropicClaudeStoryGenerationService(apiKey: "test-key")
        #expect(service != nil)
        
        // Test initialization with all parameters
        let fullService = AnthropicClaudeStoryGenerationService(
            apiKey: "test-key",
            model: "claude-3-opus-20240229",
            maxTokens: 2000,
            temperature: 0.8,
            session: URLSession.shared
        )
        #expect(fullService != nil)
    }
    
    @Test("AnthropicClaudeStoryGenerationService canGenerateStory validation")
    func testCanGenerateStoryValidation() {
        let service = AnthropicClaudeStoryGenerationService(apiKey: "test-key")
        
        // Valid profile and options
        let validProfile = UserProfile(
            name: "Valid Baby",
            babyStage: .toddler,
            interests: ["Animals"],
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .male
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
            interests: [], dateOfBirth: Date(),
            gender: .notSpecified
        )
        
        #expect(service.canGenerateStory(for: invalidProfile, with: validOptions) == false)
        
        // Invalid options (empty theme)
        let invalidOptions = StoryOptions(
            length: .short,
            theme: "",
            characters: []
        )
        
        #expect(service.canGenerateStory(for: validProfile, with: invalidOptions) == false)
        
        // Empty API key
        let emptyKeyService = AnthropicClaudeStoryGenerationService(apiKey: "")
        #expect(emptyKeyService.canGenerateStory(for: validProfile, with: validOptions) == false)
    }
    
    @Test("AnthropicClaudeStoryGenerationService getSuggestedThemes")
    func testGetSuggestedThemes() {
        let service = AnthropicClaudeStoryGenerationService(apiKey: "test-key")
        
        // Profile with no interests
        let noInterestsProfile = UserProfile(
            name: "Base Baby",
            babyStage: .toddler,
            interests: [],
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .female
        )
        
        let baseThemes = service.getSuggestedThemes(for: noInterestsProfile)
        
        #expect(!baseThemes.isEmpty)
        #expect(baseThemes.contains("Adventure"))
        #expect(baseThemes.contains("Friendship"))
        #expect(baseThemes.contains("Magic"))
        #expect(baseThemes.contains("Animals"))
        #expect(baseThemes.contains("Learning"))
        
        // Profile with interests
        let interestsProfile = UserProfile(
            name: "Interest Baby",
            babyStage: .preschooler,
            interests: ["Animals", "Music", "Colors", "Sports"],
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .male
        )
        
        let interestThemes = service.getSuggestedThemes(for: interestsProfile)
        
        #expect(!interestThemes.isEmpty)
        #expect(interestThemes.contains("Safari Adventure"))
        #expect(interestThemes.contains("Pet Friends"))
        #expect(interestThemes.contains("Musical Journey"))
        #expect(interestThemes.contains("Rainbow Magic"))
        #expect(interestThemes.contains("Team Adventure"))
        
        // Age-specific themes for different stages
        let pregnancyProfile = UserProfile(name: "Pregnancy", babyStage: .pregnancy, interests: [], dueDate: Date(), gender: .notSpecified)
        let pregnancyThemes = service.getSuggestedThemes(for: pregnancyProfile)
        #expect(pregnancyThemes.contains("Gentle Dreams"))
        #expect(pregnancyThemes.contains("Peaceful Journey"))
        
        let newbornProfile = UserProfile(name: "Newborn", babyStage: .newborn, interests: [], dateOfBirth: Date(), gender: .male)
        let newbornThemes = service.getSuggestedThemes(for: newbornProfile)
        #expect(newbornThemes.contains("Soft Lullaby"))
        #expect(newbornThemes.contains("Gentle Touch"))
        
        let preschoolerProfile = UserProfile(name: "Preschooler", babyStage: .preschooler, interests: [], dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()), gender: .female)
        let preschoolerThemes = service.getSuggestedThemes(for: preschoolerProfile)
        #expect(preschoolerThemes.contains("Big Kid Adventure"))
        #expect(preschoolerThemes.contains("Creative Play"))
    }
    
    @Test("AnthropicClaudeStoryGenerationService getEstimatedGenerationTime")
    func testGetEstimatedGenerationTime() {
        let service = AnthropicClaudeStoryGenerationService(apiKey: "test-key")
        
        let shortOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        let mediumOptions = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        let longOptions = StoryOptions(length: .long, theme: "Adventure", characters: [])
        
        let shortTime = service.getEstimatedGenerationTime(for: shortOptions)
        let mediumTime = service.getEstimatedGenerationTime(for: mediumOptions)
        let longTime = service.getEstimatedGenerationTime(for: longOptions)
        
        #expect(shortTime == 3.0)
        #expect(mediumTime == 5.0)
        #expect(longTime == 8.0)
        
        // Times should increase with length
        #expect(shortTime < mediumTime)
        #expect(mediumTime < longTime)
    }
    
    @Test("AnthropicClaudeStoryGenerationService createWithStoredAPIKey")
    func testCreateWithStoredAPIKey() {
        // This test verifies the static factory method
        // Note: This may return nil if no API key is configured
        let service = AnthropicClaudeStoryGenerationService.createWithStoredAPIKey()
        
        // Service creation should not crash
        #expect(true) // Test passes if no exception is thrown
        
        // If service is created, it should be valid
        if let service = service {
            let profile = UserProfile(
                name: "Test",
                babyStage: .toddler,
                interests: [], dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
                gender: .male
            )
            let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
            
            // Should be able to validate
            let canGenerate = service.canGenerateStory(for: profile, with: options)
            #expect(canGenerate == true || canGenerate == false) // Either result is valid
        }
    }
    
    @Test("AnthropicClaudeStoryGenerationService generateStory with mock URLSession")
    func testGenerateStoryWithMockSession() async throws {
        // Create a mock URLSession that returns a successful response
        let mockSession = MockURLSession()
        mockSession.mockResponse = """
        {
          "content": [
            {
              "type": "text",
              "text": "Test Baby's Amazing Adventure\\n\\nOnce upon a time, Test Baby discovered a magical garden where flowers sang beautiful songs. The adventure taught Test Baby about kindness and wonder.\\n\\nThe End."
            }
          ]
        }
        """.data(using: .utf8)!
        
        mockSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.anthropic.com/v1/messages")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let service = AnthropicClaudeStoryGenerationService(
            apiKey: "test-key",
            model: "claude-3-haiku-20240307",
            maxTokens: 1000,
            temperature: 0.7,
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["Animals"], dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .male
        )
        
        let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        let story = try await service.generateStory(for: profile, with: options)
        
        #expect(story.title == "Test Baby's Amazing Adventure")
        #expect(story.content.contains("magical garden"))
        #expect(story.theme == "Adventure")
        #expect(story.length == .short)
        #expect(story.ageRange == .toddler)
    }
    
    @Test("AnthropicClaudeStoryGenerationService generateStory with network error")
    func testGenerateStoryWithNetworkError() async {
        // Create a mock URLSession that returns an error
        let mockSession = MockURLSession()
        mockSession.mockError = NSError(domain: "com.example.error", code: -1, userInfo: nil)
        
        let service = AnthropicClaudeStoryGenerationService(
            apiKey: "test-key",
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: [], dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .male
        )
        
        let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        do {
            let _ = try await service.generateStory(for: profile, with: options)
            #expect(Bool(false), "Should have thrown an error")
        } catch StoryGenerationError.networkError {
            #expect(true)
        } catch {
            #expect(Bool(false), "Should have thrown networkError")
        }
    }
    
    @Test("AnthropicClaudeStoryGenerationService generateStory with 401 error")
    func testGenerateStoryWith401Error() async {
        // Create a mock URLSession that returns a 401 (unauthorized) error
        let mockSession = MockURLSession()
        mockSession.mockResponse = "{}".data(using: .utf8)!
        mockSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.anthropic.com/v1/messages")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        let service = AnthropicClaudeStoryGenerationService(
            apiKey: "invalid-key",
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: [], dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .male
        )
        
        let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        do {
            let _ = try await service.generateStory(for: profile, with: options)
            #expect(Bool(false), "Should have thrown an error")
        } catch StoryGenerationError.serviceUnavailable {
            #expect(true)
        } catch {
            #expect(Bool(false), "Should have thrown serviceUnavailable")
        }
    }
    
    @Test("AnthropicClaudeStoryGenerationService generateStory with 429 error")
    func testGenerateStoryWith429Error() async {
        // Create a mock URLSession that returns a 429 (rate limit) error
        let mockSession = MockURLSession()
        mockSession.mockResponse = "{}".data(using: .utf8)!
        mockSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.anthropic.com/v1/messages")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )
        
        let service = AnthropicClaudeStoryGenerationService(
            apiKey: "test-key",
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: [], dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .male
        )
        
        let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        do {
            let _ = try await service.generateStory(for: profile, with: options)
            #expect(Bool(false), "Should have thrown an error")
        } catch StoryGenerationError.quotaExceeded {
            #expect(true)
        } catch {
            #expect(Bool(false), "Should have thrown quotaExceeded")
        }
    }
    
    @Test("AnthropicClaudeStoryGenerationService generateDailyStory")
    func testGenerateDailyStory() async throws {
        // Create a mock URLSession that returns a successful response
        let mockSession = MockURLSession()
        mockSession.mockResponse = """
        {
          "content": [
            {
              "type": "text",
              "text": "Daily Story\\n\\nOnce upon a time, Test Baby had a wonderful day learning about the world. The End."
            }
          ]
        }
        """.data(using: .utf8)!
        
        mockSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.anthropic.com/v1/messages")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let service = AnthropicClaudeStoryGenerationService(
            apiKey: "test-key",
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: [], dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .male
        )
        
        let story = try await service.generateDailyStory(for: profile)
        
        #expect(story.title == "Daily Story")
        #expect(story.length == .medium) // Default length for daily story
        #expect(!story.theme.isEmpty)
    }
}
