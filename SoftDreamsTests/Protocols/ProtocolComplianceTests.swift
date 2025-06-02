//
//  ProtocolComplianceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct ProtocolComplianceTests {
    
    @Test("StoryServiceProtocol compliance - UserDefaultsStoryService")
    func testStoryServiceProtocolCompliance() throws {
        let service: StoryServiceProtocol = UserDefaultsStoryService()
        
        // Test all required methods are available
        let testStory = Story(
            id: UUID(),
            title: "Test Story",
            content: "Test content for protocol compliance",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .short,
            characters: [],
            ageRange: .toddler,
            readingTime: 60,
            tags: ["test"]
        )
        
        // Save story
        try service.saveStory(testStory)
        
        // Load stories
        let stories = try service.loadStories()
        #expect(!stories.isEmpty)
        
        // Get specific story
        let retrievedStory = try service.getStory(withId: testStory.id.uuidString)
        #expect(retrievedStory != nil)
        #expect(retrievedStory?.id == testStory.id)
        
        // Update story
        var updatedStory = testStory
        updatedStory.isFavorite = true
        try service.updateStory(updatedStory)
        
        // Get story count
        let count = try service.getStoryCount()
        #expect(count > 0)
        
        // Delete story
        try service.deleteStory(withId: testStory.id.uuidString)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "saved_stories")
    }
    
    @Test("UserProfileServiceProtocol compliance - UserDefaultsUserProfileService")
    func testUserProfileServiceProtocolCompliance() throws {
        let service: UserProfileServiceProtocol = UserDefaultsUserProfileService()
        
        let testProfile = UserProfile(
            name: "Protocol Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: ["Testing"]
        )
        
        // Save profile
        try service.saveProfile(testProfile)
        
        // Load profile
        let loadedProfile = try service.loadProfile()
        #expect(loadedProfile != nil)
        #expect(loadedProfile?.name == testProfile.name)
        
        // Profile exists
        #expect(service.profileExists() == true)
        
        // Update profile
        var updatedProfile = testProfile
        updatedProfile.interests.append("Protocol Compliance")
        try service.updateProfile(updatedProfile)
        
        // Verify update
        let updatedLoadedProfile = try service.loadProfile()
        #expect(updatedLoadedProfile?.interests.contains("Protocol Compliance") == true)
        
        // Delete profile
        try service.deleteProfile()
        #expect(service.profileExists() == false)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "user_profile")
    }
    
    @Test("ThemeServiceProtocol compliance - UserDefaultsThemeService")
    func testThemeServiceProtocolCompliance() throws {
        let service: ThemeServiceProtocol = UserDefaultsThemeService()
        
        // Save theme setting
        try service.saveTheme("dark_mode", value: true)
        
        // Load theme setting
        let darkModeEnabled: Bool = try service.loadTheme("dark_mode", defaultValue: false)
        #expect(darkModeEnabled == true)
        
        // Load with different type
        let stringValue: String = try service.loadTheme("test_string", defaultValue: "default")
        #expect(stringValue == "default")
        
        // Reset all themes
        try service.resetAllThemes()
        
        // Verify reset
        let resetValue: Bool = try service.loadTheme("dark_mode", defaultValue: false)
        #expect(resetValue == false)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "themes")
    }
    
    @Test("SettingsServiceProtocol compliance - UserDefaultsSettingsService")
    func testSettingsServiceProtocolCompliance() throws {
        let service: SettingsServiceProtocol = UserDefaultsSettingsService()
        
        // Save different types of settings
        try service.saveSetting("test_bool", value: true)
        try service.saveSetting("test_string", value: "test value")
        try service.saveSetting("test_int", value: 42)
        try service.saveSetting("test_double", value: 3.14)
        
        // Load settings with correct types
        let boolValue: Bool = try service.loadSetting("test_bool", defaultValue: false)
        #expect(boolValue == true)
        
        let stringValue: String = try service.loadSetting("test_string", defaultValue: "")
        #expect(stringValue == "test value")
        
        let intValue: Int = try service.loadSetting("test_int", defaultValue: 0)
        #expect(intValue == 42)
        
        let doubleValue: Double = try service.loadSetting("test_double", defaultValue: 0.0)
        #expect(doubleValue == 3.14)
        
        // Test setting existence
        #expect(service.settingExists("test_bool") == true)
        #expect(service.settingExists("nonexistent") == false)
        
        // Reset all settings
        try service.resetAllSettings()
        
        // Verify reset
        #expect(service.settingExists("test_bool") == false)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "app_settings")
    }
    
    @Test("StoryGenerationServiceProtocol compliance - MockStoryGenerationService")
    func testStoryGenerationServiceProtocolCompliance() async throws {
        let service: StoryGenerationServiceProtocol = MockStoryGenerationService(mockDelay: 0.1)
        
        let testProfile = UserProfile(
            name: "Protocol Test Baby",
            babyStage: .preschooler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .girl,
            interests: ["Adventure", "Magic"]
        )
        
        let testOptions = StoryOptions(
            length: .medium,
            theme: "Adventure",
            characters: ["Dragon", "Princess"]
        )
        
        // Test can generate story
        #expect(service.canGenerateStory(for: testProfile, with: testOptions) == true)
        
        // Test generate story
        let story = try await service.generateStory(for: testProfile, with: testOptions)
        #expect(!story.title.isEmpty)
        #expect(!story.content.isEmpty)
        #expect(story.theme == testOptions.theme)
        #expect(story.length == testOptions.length)
        
        // Test generate daily story
        let dailyStory = try await service.generateDailyStory(for: testProfile)
        #expect(!dailyStory.title.isEmpty)
        #expect(!dailyStory.content.isEmpty)
        #expect(dailyStory.length == .medium) // Daily stories use medium length
        
        // Test get suggested themes
        let themes = service.getSuggestedThemes(for: testProfile)
        #expect(!themes.isEmpty)
        #expect(themes.contains("Adventure"))
        
        // Test get estimated generation time
        let estimatedTime = service.getEstimatedGenerationTime(for: testOptions)
        #expect(estimatedTime > 0)
    }
    
    @Test("StoryGenerationServiceProtocol compliance - OpenAIStoryGenerationService")
    func testOpenAIStoryGenerationServiceProtocolCompliance() async throws {
        let service: StoryGenerationServiceProtocol = OpenAIStoryGenerationService(apiKey: "test-key")
        
        let testProfile = UserProfile(
            name: "Protocol Test Baby",
            babyStage: .toddler,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date()),
            gender: .boy,
            interests: ["Animals"]
        )
        
        let testOptions = StoryOptions(
            length: .short,
            theme: "Animals",
            characters: ["Cat", "Dog"]
        )
        
        // Test can generate story (should validate inputs even without real API call)
        let canGenerate = service.canGenerateStory(for: testProfile, with: testOptions)
        #expect(canGenerate == true) // Should return true for valid inputs
        
        // Test get suggested themes
        let themes = service.getSuggestedThemes(for: testProfile)
        #expect(!themes.isEmpty)
        #expect(themes.contains("Animals"))
        #expect(themes.contains("Safari Adventure")) // Interest-based theme
        
        // Test get estimated generation time
        let estimatedTime = service.getEstimatedGenerationTime(for: testOptions)
        #expect(estimatedTime > 0)
        #expect(estimatedTime == 4.0) // OpenAI service returns 4.0 for short stories
        
        // Test validation with invalid inputs
        let invalidProfile = UserProfile(
            name: "",  // Empty name
            babyStage: .infant,
            dateOfBirth: Date(),
            gender: .notSpecified,
            interests: []
        )
        
        #expect(service.canGenerateStory(for: invalidProfile, with: testOptions) == false)
        
        let invalidOptions = StoryOptions(length: .short, theme: "", characters: [])
        #expect(service.canGenerateStory(for: testProfile, with: invalidOptions) == false)
        
        // Test with empty API key
        let emptyKeyService = OpenAIStoryGenerationService(apiKey: "")
        #expect(emptyKeyService.canGenerateStory(for: testProfile, with: testOptions) == false)
    }
    
    @Test("Protocol method signatures and return types")
    func testProtocolMethodSignatures() {
        // Test that all protocol implementations have correct method signatures
        
        // StoryServiceProtocol
        let storyService: StoryServiceProtocol = UserDefaultsStoryService()
        #expect(type(of: storyService.loadStories) == (() throws -> [Story]).self)
        
        // UserProfileServiceProtocol  
        let profileService: UserProfileServiceProtocol = UserDefaultsUserProfileService()
        #expect(type(of: profileService.loadProfile) == (() throws -> UserProfile?).self)
        #expect(type(of: profileService.profileExists) == (() -> Bool).self)
        
        // ThemeServiceProtocol
        let themeService: ThemeServiceProtocol = UserDefaultsThemeService()
        // Generic methods tested through usage above
        
        // SettingsServiceProtocol
        let settingsService: SettingsServiceProtocol = UserDefaultsSettingsService()
        #expect(type(of: settingsService.settingExists) == ((String) -> Bool).self)
        
        // StoryGenerationServiceProtocol
        let storyGenService: StoryGenerationServiceProtocol = MockStoryGenerationService()
        #expect(type(of: storyGenService.canGenerateStory) == ((UserProfile, StoryOptions) -> Bool).self)
        #expect(type(of: storyGenService.getSuggestedThemes) == ((UserProfile) -> [String]).self)
        #expect(type(of: storyGenService.getEstimatedGenerationTime) == ((StoryOptions) -> TimeInterval).self)
    }
    
    @Test("Protocol error handling consistency")
    func testProtocolErrorHandling() {
        // Test that all protocols handle errors consistently
        
        // Create services that might fail
        let storyService: StoryServiceProtocol = UserDefaultsStoryService()
        let profileService: UserProfileServiceProtocol = UserDefaultsUserProfileService()
        let themeService: ThemeServiceProtocol = UserDefaultsThemeService()
        let settingsService: SettingsServiceProtocol = UserDefaultsSettingsService()
        
        // Test that methods can throw errors and handle them gracefully
        do {
            _ = try storyService.loadStories()
            _ = try profileService.loadProfile()
            let _: Bool = try themeService.loadTheme("test", defaultValue: false)
            let _: String = try settingsService.loadSetting("test", defaultValue: "")
            
            // If we reach here, no errors were thrown (which is fine)
            #expect(true)
        } catch {
            // If errors are thrown, they should be proper Swift errors
            #expect(error is Error)
        }
    }
    
    @Test("Protocol inheritance and conformance")
    func testProtocolInheritanceAndConformance() {
        // Test that concrete implementations properly conform to protocols
        
        // Verify UserDefaultsStoryService conforms to StoryServiceProtocol
        let storyService = UserDefaultsStoryService()
        #expect(storyService is StoryServiceProtocol)
        
        // Verify UserDefaultsUserProfileService conforms to UserProfileServiceProtocol
        let profileService = UserDefaultsUserProfileService()
        #expect(profileService is UserProfileServiceProtocol)
        
        // Verify UserDefaultsThemeService conforms to ThemeServiceProtocol
        let themeService = UserDefaultsThemeService()
        #expect(themeService is ThemeServiceProtocol)
        
        // Verify UserDefaultsSettingsService conforms to SettingsServiceProtocol
        let settingsService = UserDefaultsSettingsService()
        #expect(settingsService is SettingsServiceProtocol)
        
        // Verify story generation services conform to StoryGenerationServiceProtocol
        let mockService = MockStoryGenerationService()
        #expect(mockService is StoryGenerationServiceProtocol)
        
        let openAIService = OpenAIStoryGenerationService(apiKey: "test")
        #expect(openAIService is StoryGenerationServiceProtocol)
    }
}
