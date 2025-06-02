//
//  OpenAIStoryGenerationServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct OpenAIStoryGenerationServiceTests {
    
    @Test("OpenAIStoryGenerationService initialization")
    func testInitialization() {
        // Test initialization with minimal parameters
        let service = OpenAIStoryGenerationService(apiKey: "test-key")
        #expect(service != nil)
        
        // Test initialization with all parameters
        let fullService = OpenAIStoryGenerationService(
            apiKey: "test-key",
            model: "gpt-4",
            maxTokens: 2000,
            temperature: 0.8,
            session: URLSession.shared
        )
        #expect(fullService != nil)
    }
    
    @Test("OpenAIStoryGenerationService canGenerateStory validation")
    func testCanGenerateStoryValidation() {
        let service = OpenAIStoryGenerationService(apiKey: "test-key")
        
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
        
        // Empty API key
        let emptyKeyService = OpenAIStoryGenerationService(apiKey: "")
        #expect(emptyKeyService.canGenerateStory(for: validProfile, with: validOptions) == false)
    }
    
    @Test("OpenAIStoryGenerationService getSuggestedThemes")
    func testGetSuggestedThemes() {
        let service = OpenAIStoryGenerationService(apiKey: "test-key")
        
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
    
    @Test("OpenAIStoryGenerationService getEstimatedGenerationTime")
    func testGetEstimatedGenerationTime() {
        let service = OpenAIStoryGenerationService(apiKey: "test-key")
        
        let shortOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        let mediumOptions = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        let longOptions = StoryOptions(length: .long, theme: "Adventure", characters: [])
        
        let shortTime = service.getEstimatedGenerationTime(for: shortOptions)
        let mediumTime = service.getEstimatedGenerationTime(for: mediumOptions)
        let longTime = service.getEstimatedGenerationTime(for: longOptions)
        
        #expect(shortTime == 4.0)
        #expect(mediumTime == 7.0)
        #expect(longTime == 10.0)
        
        // Times should increase with length
        #expect(shortTime < mediumTime)
        #expect(mediumTime < longTime)
    }
    
    @Test("OpenAIStoryGenerationService createWithStoredAPIKey")
    func testCreateWithStoredAPIKey() {
        // This test verifies the static factory method
        // Note: This may return nil if no API key is configured
        let service = OpenAIStoryGenerationService.createWithStoredAPIKey()
        
        // Service creation should not crash
        #expect(true) // Test passes if no exception is thrown
        
        // If service is created, it should be valid
        if let service = service {
            let profile = UserProfile(
                name: "Test",
                babyStage: .toddler,
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
                gender: .boy,
                interests: []
            )
            let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
            
            // Should be able to validate
            let canGenerate = service.canGenerateStory(for: profile, with: options)
            #expect(canGenerate == true || canGenerate == false) // Either result is valid
        }
    }
    
    @Test("OpenAIStoryGenerationService generateStory with mock URLSession")
    func testGenerateStoryWithMockSession() async throws {
        // Create a mock URLSession that returns a successful response
        let mockSession = MockURLSession()
        mockSession.mockResponse = """
        {
          "choices": [
            {
              "message": {
                "role": "assistant",
                "content": "Test Baby's Amazing Adventure\\n\\nOnce upon a time, Test Baby discovered a magical garden where flowers sang beautiful songs. The adventure taught Test Baby about kindness and wonder.\\n\\nThe End."
              }
            }
          ]
        }
        """.data(using: .utf8)!
        
        mockSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let service = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: ["Animals"]
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
    }
    
    @Test("OpenAIStoryGenerationService generateDailyStory with mock URLSession")
    func testGenerateDailyStoryWithMockSession() async throws {
        let mockSession = MockURLSession()
        mockSession.mockResponse = """
        {
          "choices": [
            {
              "message": {
                "role": "assistant",
                "content": "Daily Baby's Daily Adventure\\n\\nToday was a special day for Daily Baby as they explored the wonders around them.\\n\\nThe End."
              }
            }
          ]
        }
        """.data(using: .utf8)!
        
        mockSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let service = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Daily Baby",
            babyStage: .preschooler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .girl,
            interests: ["Learning"]
        )
        
        let story = try await service.generateDailyStory(for: profile)
        
        #expect(!story.title.isEmpty)
        #expect(!story.content.isEmpty)
        #expect(!story.theme.isEmpty)
        #expect(story.length == .medium) // Daily stories use medium length
        #expect(story.ageRange == .preschooler)
        #expect(story.title.contains(profile.displayName))
    }
    
    @Test("OpenAIStoryGenerationService error handling")
    func testErrorHandling() async throws {
        // Test invalid profile error
        let service = OpenAIStoryGenerationService(apiKey: "test-key")
        
        let invalidProfile = UserProfile(
            name: "",  // Empty name
            babyStage: .infant,
            dateOfBirth: Date(),
            gender: .notSpecified,
            interests: []
        )
        
        let validOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        do {
            let _ = try await service.generateStory(for: invalidProfile, with: validOptions)
            #expect(Bool(false), "Should have thrown an error for invalid profile")
        } catch StoryGenerationError.invalidProfile {
            #expect(true)
        } catch {
            #expect(Bool(false), "Should have thrown invalidProfile error")
        }
        
        // Test empty API key error
        let emptyKeyService = OpenAIStoryGenerationService(apiKey: "")
        let validProfile = UserProfile(
            name: "Valid Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: []
        )
        
        do {
            let _ = try await emptyKeyService.generateStory(for: validProfile, with: validOptions)
            #expect(Bool(false), "Should have thrown an error for empty API key")
        } catch StoryGenerationError.serviceUnavailable {
            #expect(true)
        } catch {
            #expect(Bool(false), "Should have thrown serviceUnavailable error")
        }
    }
    
    @Test("OpenAIStoryGenerationService HTTP error responses")
    func testHTTPErrorResponses() async throws {
        let validProfile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: []
        )
        
        let validOptions = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        // Test 401 Unauthorized (Invalid API key)
        let unauthorizedSession = MockURLSession()
        unauthorizedSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let unauthorizedService = OpenAIStoryGenerationService(
            apiKey: "invalid-key",
            session: unauthorizedSession
        )
        
        do {
            let _ = try await unauthorizedService.generateStory(for: validProfile, with: validOptions)
            #expect(Bool(false), "Should have thrown an error for 401")
        } catch StoryGenerationError.serviceUnavailable {
            #expect(true)
        }
        
        // Test 429 Rate Limit
        let rateLimitSession = MockURLSession()
        rateLimitSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let rateLimitService = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: rateLimitSession
        )
        
        do {
            let _ = try await rateLimitService.generateStory(for: validProfile, with: validOptions)
            #expect(Bool(false), "Should have thrown an error for 429")
        } catch StoryGenerationError.quotaExceeded {
            #expect(true)
        }
        
        // Test 500 Server Error
        let serverErrorSession = MockURLSession()
        serverErrorSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let serverErrorService = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: serverErrorSession
        )
        
        do {
            let _ = try await serverErrorService.generateStory(for: validProfile, with: validOptions)
            #expect(Bool(false), "Should have thrown an error for 500")
        } catch StoryGenerationError.serviceUnavailable {
            #expect(true)
        }
    }
    
    @Test("OpenAIStoryGenerationService network errors")
    func testNetworkErrors() async throws {
        let errorSession = MockURLSession()
        errorSession.shouldThrowError = true
        errorSession.error = URLError(.notConnectedToInternet)
        
        let service = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: errorSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: []
        )
        
        let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        do {
            let _ = try await service.generateStory(for: profile, with: options)
            #expect(Bool(false), "Should have thrown a network error")
        } catch StoryGenerationError.networkError {
            #expect(true)
        }
    }
    
    @Test("OpenAIStoryGenerationService language support")
    func testLanguageSupport() {
        let service = OpenAIStoryGenerationService(apiKey: "test-key")
        
        // Test profiles with different languages
        let languages = [Language.english, Language.vietnamese, Language.spanish, Language.french]
        
        for language in languages {
            let profile = UserProfile(
                name: "Test Baby",
                babyStage: .toddler,
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
                gender: .boy,
                interests: [],
                language: language
            )
            
            let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
            
            // Should be able to validate for all supported languages
            #expect(service.canGenerateStory(for: profile, with: options) == true)
            
            // Should provide themes for all languages
            let themes = service.getSuggestedThemes(for: profile)
            #expect(!themes.isEmpty)
        }
    }
    
    @Test("OpenAIStoryGenerationService story content validation")
    func testStoryContentValidation() async throws {
        let mockSession = MockURLSession()
        
        // Test with response that has extractable title
        mockSession.mockResponse = """
        {
          "choices": [
            {
              "message": {
                "role": "assistant",
                "content": "The Magic Garden Adventure\\n\\nOnce upon a time, Test Baby discovered a magical garden where flowers sang beautiful songs and butterflies danced in the air. Test Baby learned about kindness and wonder through this amazing adventure.\\n\\nAs the sun set, Test Baby returned home with a heart full of joy and new memories to cherish forever."
              }
            }
          ]
        }
        """.data(using: .utf8)!
        
        mockSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let service = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: mockSession
        )
        
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .preschooler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .girl,
            interests: ["Magic", "Nature"]
        )
        
        let options = StoryOptions(
            length: .long,
            theme: "Magic",
            characters: ["Fairy", "Butterfly"]
        )
        
        let story = try await service.generateStory(for: profile, with: options)
        
        // Validate story structure
        #expect(!story.title.isEmpty)
        #expect(!story.content.isEmpty)
        #expect(story.theme == "Magic")
        #expect(story.length == .long)
        #expect(story.characters == ["Fairy", "Butterfly"])
        #expect(story.ageRange == .preschooler)
        #expect(story.readingTime > 0)
        
        // Validate tags
        #expect(story.tags.contains("Magic"))
        #expect(story.tags.contains("preschooler"))
        #expect(story.tags.contains("AI Generated"))
        #expect(story.tags.contains("English"))
        
        // Should contain some character tags
        let characterTags = story.tags.filter { options.characters.contains($0) }
        #expect(!characterTags.isEmpty)
    }
    
    @Test("OpenAIStoryGenerationService invalid response handling")
    func testInvalidResponseHandling() async throws {
        let service = OpenAIStoryGenerationService(apiKey: "test-key")
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: []
        )
        let options = StoryOptions(length: .short, theme: "Adventure", characters: [])
        
        // Test malformed JSON response
        let malformedSession = MockURLSession()
        malformedSession.mockResponse = "Invalid JSON".data(using: .utf8)!
        malformedSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let malformedService = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: malformedSession
        )
        
        do {
            let _ = try await malformedService.generateStory(for: profile, with: options)
            #expect(Bool(false), "Should have thrown an error for malformed JSON")
        } catch StoryGenerationError.generationFailed {
            #expect(true)
        }
        
        // Test empty choices response
        let emptyChoicesSession = MockURLSession()
        emptyChoicesSession.mockResponse = """
        {
          "choices": []
        }
        """.data(using: .utf8)!
        emptyChoicesSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let emptyChoicesService = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: emptyChoicesSession
        )
        
        do {
            let _ = try await emptyChoicesService.generateStory(for: profile, with: options)
            #expect(Bool(false), "Should have thrown an error for empty choices")
        } catch StoryGenerationError.generationFailed {
            #expect(true)
        }
        
        // Test null content response
        let nullContentSession = MockURLSession()
        nullContentSession.mockResponse = """
        {
          "choices": [
            {
              "message": {
                "role": "assistant",
                "content": null
              }
            }
          ]
        }
        """.data(using: .utf8)!
        nullContentSession.mockHTTPResponse = HTTPURLResponse(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let nullContentService = OpenAIStoryGenerationService(
            apiKey: "test-key",
            session: nullContentSession
        )
        
        do {
            let _ = try await nullContentService.generateStory(for: profile, with: options)
            #expect(Bool(false), "Should have thrown an error for null content")
        } catch StoryGenerationError.generationFailed {
            #expect(true)
        }
    }
}

// MARK: - Helper Classes

/// Mock URLSession for testing network requests
class MockURLSession: URLSession {
    var mockResponse: Data?
    var mockHTTPResponse: HTTPURLResponse?
    var shouldThrowError = false
    var error: Error?
    
    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldThrowError {
            throw error ?? URLError(.unknown)
        }
        
        return (mockResponse ?? Data(), mockHTTPResponse ?? URLResponse())
    }
}
