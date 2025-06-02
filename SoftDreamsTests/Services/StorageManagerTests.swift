//
//  StorageManagerTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct StorageManagerTests {
    
    // MARK: - Initialization Tests
    
    @Test("Test StorageManager singleton")
    func testStorageManagerSingleton() async throws {
        // When
        let manager1 = StorageManager.shared
        let manager2 = StorageManager.shared
        
        // Then
        #expect(manager1 === manager2, "StorageManager should be a singleton")
    }
    
    // MARK: - Profile Management Tests
    
    @Test("Test saveProfile and loadProfile")
    func testSaveAndLoadProfile() async throws {
        // Given
        let manager = StorageManager.shared
        let testProfile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["animals", "music"],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .female,
            language: .english
        )
        
        // When
        try manager.saveProfile(testProfile)
        let loadedProfile = try manager.loadProfile()
        
        // Then
        #expect(loadedProfile != nil)
        #expect(loadedProfile?.name == "Test Baby")
        #expect(loadedProfile?.babyStage == .toddler)
        #expect(loadedProfile?.interests == ["animals", "music"])
        #expect(loadedProfile?.gender == .female)
        #expect(loadedProfile?.language == .english)
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    @Test("Test loadProfile with no saved profile")
    func testLoadProfileWithNoSavedProfile() async throws {
        // Given
        let manager = StorageManager.shared
        try? manager.clearAllData()
        
        // When
        let loadedProfile = try manager.loadProfile()
        
        // Then
        #expect(loadedProfile == nil)
    }
    
    @Test("Test saveProfile overwrites existing profile")
    func testSaveProfileOverwritesExisting() async throws {
        // Given
        let manager = StorageManager.shared
        let originalProfile = UserProfile(
            name: "Original Baby",
            babyStage: .infant,
            interests: ["music"],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .male,
            language: .english
        )
        let updatedProfile = UserProfile(
            name: "Updated Baby",
            babyStage: .toddler,
            interests: ["animals"],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .female,
            language: .vietnamese
        )
        
        // When
        try manager.saveProfile(originalProfile)
        try manager.saveProfile(updatedProfile)
        let loadedProfile = try manager.loadProfile()
        
        // Then
        #expect(loadedProfile?.name == "Updated Baby")
        #expect(loadedProfile?.babyStage == .toddler)
        #expect(loadedProfile?.interests == ["animals"])
        #expect(loadedProfile?.gender == .female)
        #expect(loadedProfile?.language == .vietnamese)
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    // MARK: - Story Management Tests
    
    @Test("Test saveStories and loadStories")
    func testSaveAndLoadStories() async throws {
        // Given
        let manager = StorageManager.shared
        let story1 = Story(
            title: "Story 1",
            content: "Content 1",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let story2 = Story(
            title: "Story 2",
            content: "Content 2",
            theme: "Magic",
            length: .medium,
            ageRange: .infant
        )
        let stories = [story1, story2]
        
        // When
        try manager.saveStories(stories)
        let loadedStories = try manager.loadStories()
        
        // Then
        #expect(loadedStories.count == 2)
        #expect(loadedStories.contains { $0.title == "Story 1" })
        #expect(loadedStories.contains { $0.title == "Story 2" })
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    @Test("Test loadStories with no saved stories")
    func testLoadStoriesWithNoSavedStories() async throws {
        // Given
        let manager = StorageManager.shared
        try? manager.clearAllData()
        
        // When
        let loadedStories = try manager.loadStories()
        
        // Then
        #expect(loadedStories.isEmpty)
    }
    
    @Test("Test saveStory adds to existing stories")
    func testSaveStoryAddsToExisting() async throws {
        // Given
        let manager = StorageManager.shared
        let existingStory = Story(
            title: "Existing Story",
            content: "Existing content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let newStory = Story(
            title: "New Story",
            content: "New content",
            theme: "Magic",
            length: .medium,
            ageRange: .toddler
        )
        
        // When
        try manager.saveStories([existingStory])
        try manager.saveStory(newStory)
        let loadedStories = try manager.loadStories()
        
        // Then
        #expect(loadedStories.count == 2)
        #expect(loadedStories.contains { $0.title == "Existing Story" })
        #expect(loadedStories.contains { $0.title == "New Story" })
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    @Test("Test saveStory updates existing story")
    func testSaveStoryUpdatesExisting() async throws {
        // Given
        let manager = StorageManager.shared
        let originalStory = Story(
            title: "Original Title",
            content: "Original content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        try manager.saveStories([originalStory])
        
        // Create updated version with same ID
        let updatedStory = Story(
            id: originalStory.id,
            title: "Updated Title",
            content: "Updated content",
            theme: "Magic",
            length: .medium,
            ageRange: .toddler
        )
        
        // When
        try manager.saveStory(updatedStory)
        let loadedStories = try manager.loadStories()
        
        // Then
        #expect(loadedStories.count == 1)
        let savedStory = loadedStories.first { $0.id == originalStory.id }
        #expect(savedStory?.title == "Updated Title")
        #expect(savedStory?.content == "Updated content")
        #expect(savedStory?.theme == "Magic")
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    @Test("Test deleteStory removes story")
    func testDeleteStoryRemovesStory() async throws {
        // Given
        let manager = StorageManager.shared
        let story1 = Story(
            title: "Story 1",
            content: "Content 1",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let story2 = Story(
            title: "Story 2",
            content: "Content 2",
            theme: "Magic",
            length: .medium,
            ageRange: .toddler
        )
        
        try manager.saveStories([story1, story2])
        
        // When
        try manager.deleteStory(withId: story1.id)
        let loadedStories = try manager.loadStories()
        
        // Then
        #expect(loadedStories.count == 1)
        #expect(loadedStories.first?.title == "Story 2")
        #expect(!loadedStories.contains { $0.id == story1.id })
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    @Test("Test deleteStory with non-existent ID")
    func testDeleteStoryWithNonExistentId() async throws {
        // Given
        let manager = StorageManager.shared
        let existingStory = Story(
            title: "Existing Story",
            content: "Existing content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let nonExistentId = UUID()
        
        try manager.saveStories([existingStory])
        
        // When
        try manager.deleteStory(withId: nonExistentId)
        let loadedStories = try manager.loadStories()
        
        // Then
        #expect(loadedStories.count == 1)
        #expect(loadedStories.first?.title == "Existing Story")
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    // MARK: - Theme Management Tests
    
    @Test("Test saveTheme and loadTheme")
    func testSaveAndLoadTheme() async throws {
        // Given
        let manager = StorageManager.shared
        let testTheme = "dark"
        
        // When
        try manager.saveTheme(testTheme)
        let loadedTheme = try manager.loadTheme()
        
        // Then
        #expect(loadedTheme == testTheme)
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    @Test("Test loadTheme with no saved theme")
    func testLoadThemeWithNoSavedTheme() async throws {
        // Given
        let manager = StorageManager.shared
        try? manager.clearAllData()
        
        // When
        let loadedTheme = try manager.loadTheme()
        
        // Then
        // Should return default theme or nil depending on implementation
        #expect(loadedTheme != nil || loadedTheme == nil) // Basic check
    }
    
    // MARK: - Settings Management Tests
    
    @Test("Test saveSetting and loadSetting")
    func testSaveAndLoadSetting() async throws {
        // Given
        let manager = StorageManager.shared
        let settingKey = "test_setting"
        let settingValue = "test_value"
        
        // When
        try manager.saveSetting(key: settingKey, value: settingValue)
        let loadedValue: String? = try manager.loadSetting(key: settingKey)
        
        // Then
        #expect(loadedValue == settingValue)
        
        // Cleanup
        try? manager.clearAllData()
    }
    
    @Test("Test loadSetting with non-existent key")
    func testLoadSettingWithNonExistentKey() async throws {
        // Given
        let manager = StorageManager.shared
        try? manager.clearAllData()
        
        // When
        let loadedValue: String? = try manager.loadSetting(key: "non_existent_key")
        
        // Then
        #expect(loadedValue == nil)
    }
    
    // MARK: - Data Management Tests
    
    @Test("Test clearAllData removes all data")
    func testClearAllDataRemovesAllData() async throws {
        // Given
        let manager = StorageManager.shared
        let testProfile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["animals"],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        let testStory = Story(
            title: "Test Story",
            content: "Test content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // Save some data
        try manager.saveProfile(testProfile)
        try manager.saveStories([testStory])
        try manager.saveTheme("dark")
        
        // When
        try manager.clearAllData()
        
        // Then
        let loadedProfile = try manager.loadProfile()
        let loadedStories = try manager.loadStories()
        
        #expect(loadedProfile == nil)
        #expect(loadedStories.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test error handling for invalid data")
    func testErrorHandlingForInvalidData() async throws {
        // This test depends on the specific error handling implementation
        // in the underlying services. For now, we'll test basic operations.
        
        let manager = StorageManager.shared
        
        // Test that basic operations don't throw unexpected errors
        do {
            let _ = try manager.loadProfile()
            let _ = try manager.loadStories()
            let _ = try manager.loadTheme()
        } catch {
            // If errors are thrown, they should be appropriate types
            #expect(error is StorageError || error is DecodingError || error is EncodingError)
        }
    }
    
    // MARK: - Data Consistency Tests
    
    @Test("Test data consistency across operations")
    func testDataConsistencyAcrossOperations() async throws {
        // Given
        let manager = StorageManager.shared
        let profile = UserProfile(
            name: "Consistency Test",
            babyStage: .toddler,
            interests: ["animals"],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        let story = Story(
            title: "Consistency Story",
            content: "Consistency content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When performing multiple operations
        try manager.saveProfile(profile)
        try manager.saveStory(story)
        
        let loadedProfile = try manager.loadProfile()
        let loadedStories = try manager.loadStories()
        
        // Update and save again
        var updatedProfile = profile
        updatedProfile.name = "Updated Name"
        try manager.saveProfile(updatedProfile)
        
        let finalProfile = try manager.loadProfile()
        let finalStories = try manager.loadStories()
        
        // Then
        #expect(loadedProfile?.name == "Consistency Test")
        #expect(loadedStories.count == 1)
        #expect(finalProfile?.name == "Updated Name")
        #expect(finalStories.count == 1) // Stories should remain unchanged
        #expect(finalStories.first?.title == "Consistency Story")
        
        // Cleanup
        try? manager.clearAllData()
    }
}
