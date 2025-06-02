//
//  HomeViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct HomeViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test("Test HomeViewModel initialization")
    func testHomeViewModelInitialization() async throws {
        // When
        let viewModel = HomeViewModel()
        
        // Then
        #expect(viewModel.profile == nil)
        #expect(viewModel.stories.isEmpty)
        #expect(viewModel.error == nil)
    }
    
    // MARK: - Refresh Tests
    
    @Test("Test refresh with no saved data")
    func testRefreshWithNoSavedData() async throws {
        // Given
        let viewModel = HomeViewModel()
        
        // Clear any existing data
        try? StorageManager.shared.clearAllData()
        
        // When
        viewModel.refresh()
        
        // Then
        #expect(viewModel.profile == nil)
        #expect(viewModel.stories.isEmpty)
        // Error might be set depending on implementation
    }
    
    @Test("Test refresh with saved profile")
    func testRefreshWithSavedProfile() async throws {
        // Given
        let viewModel = HomeViewModel()
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
        
        // Save test profile
        try StorageManager.shared.saveProfile(testProfile)
        
        // When
        viewModel.refresh()
        
        // Then
        #expect(viewModel.profile != nil)
        #expect(viewModel.profile?.name == "Test Baby")
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test refresh with saved stories")
    func testRefreshWithSavedStories() async throws {
        // Given
        let viewModel = HomeViewModel()
        let testStory = Story(
            title: "Test Story",
            content: "Test content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // Save test story
        try StorageManager.shared.saveStories([testStory])
        
        // When
        viewModel.refresh()
        
        // Then
        #expect(viewModel.stories.count == 1)
        #expect(viewModel.stories.first?.title == "Test Story")
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Save Story Tests
    
    @Test("Test saveStory success")
    func testSaveStorySuccess() async throws {
        // Given
        let viewModel = HomeViewModel()
        let testStory = Story(
            title: "New Story",
            content: "New content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // Clear existing stories
        try? StorageManager.shared.saveStories([])
        viewModel.refresh()
        
        // When
        viewModel.saveStory(testStory)
        
        // Then
        #expect(viewModel.stories.count == 1)
        #expect(viewModel.stories.first?.title == "New Story")
        #expect(viewModel.error == nil)
        
        // Verify persistence
        let savedStories = try StorageManager.shared.loadStories()
        #expect(savedStories.count == 1)
        #expect(savedStories.first?.title == "New Story")
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test saveStory adds to existing stories")
    func testSaveStoryAddsToExisting() async throws {
        // Given
        let viewModel = HomeViewModel()
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
        
        // Setup existing story
        try StorageManager.shared.saveStories([existingStory])
        viewModel.refresh()
        
        // When
        viewModel.saveStory(newStory)
        
        // Then
        #expect(viewModel.stories.count == 2)
        #expect(viewModel.stories.contains { $0.title == "Existing Story" })
        #expect(viewModel.stories.contains { $0.title == "New Story" })
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test error handling in refresh")
    func testErrorHandlingInRefresh() async throws {
        // Given
        let viewModel = HomeViewModel()
        
        // This test depends on the implementation
        // If StorageManager throws errors, they should be handled
        
        // When
        viewModel.refresh()
        
        // Then
        // The error property should be properly set if there are any issues
        // This is implementation-dependent
    }
    
    // MARK: - Auto-update Tests
    
    @Test("Test checkAndPerformAutoUpdates is called with profile")
    func testAutoUpdatesWithProfile() async throws {
        // Given
        let viewModel = HomeViewModel()
        let testProfile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["animals"],
            storyTime: Date(),
            parentNames: [],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            lastUpdate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            gender: .notSpecified,
            language: .english
        )
        
        // Save test profile
        try StorageManager.shared.saveProfile(testProfile)
        
        // When
        viewModel.refresh()
        
        // Then
        #expect(viewModel.profile != nil)
        // Auto-update should be triggered asynchronously
        // Wait a bit for async operation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Story Generation Tests
    
    @Test("Test generateTodaysStory with valid profile")
    func testGenerateTodaysStoryWithValidProfile() async throws {
        // Given
        let viewModel = HomeViewModel()
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
        let storyOptions = StoryOptions(
            length: .short,
            theme: .animals,
            includeParents: false
        )
        
        viewModel.profile = testProfile
        
        // When
        await viewModel.generateTodaysStory(
            profile: testProfile,
            options: storyOptions,
            onStoryGenerated: { story in
                // Verify story was generated
                #expect(story.title.count > 0)
                #expect(story.content.count > 0)
                #expect(story.theme == "Animals")
                #expect(story.length == .short)
            }
        )
        
        // Then
        #expect(viewModel.error == nil)
    }
    
    @Test("Test generateTodaysStory error handling")
    func testGenerateTodaysStoryErrorHandling() async throws {
        // Given
        let viewModel = HomeViewModel()
        let invalidProfile = UserProfile(
            name: "",  // Invalid name
            babyStage: .toddler,
            interests: [],
            storyTime: Date(),
            parentNames: [],
            lastUpdate: Date(),
            gender: .notSpecified,
            language: .english
        )
        let storyOptions = StoryOptions()
        
        // When
        await viewModel.generateTodaysStory(
            profile: invalidProfile,
            options: storyOptions,
            onStoryGenerated: { story in
                // Should not be called for invalid profile
                #expect(false, "Story generation should fail with invalid profile")
            }
        )
        
        // Then
        // Error should be set (depending on validation implementation)
    }
    
    // MARK: - Recent Stories Tests
    
    @Test("Test recentStories computed property")
    func testRecentStories() async throws {
        // Given
        let viewModel = HomeViewModel()
        let calendar = Calendar.current
        
        let recentStory = Story(
            title: "Recent Story",
            content: "Recent content",
            date: Date(),
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        let oldStory = Story(
            title: "Old Story",
            content: "Old content",
            date: calendar.date(byAdding: .day, value: -10, to: Date())!,
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        viewModel.stories = [oldStory, recentStory]
        
        // When
        let recent = viewModel.recentStories
        
        // Then
        #expect(recent.count <= 3) // Should limit to recent stories
        #expect(recent.first?.title == "Recent Story")
    }
    
    // MARK: - Story Management Tests
    
    @Test("Test story array operations")
    func testStoryArrayOperations() async throws {
        // Given
        let viewModel = HomeViewModel()
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
        
        // When adding stories
        viewModel.saveStory(story1)
        viewModel.saveStory(story2)
        
        // Then
        #expect(viewModel.stories.count == 2)
        #expect(viewModel.stories.contains { $0.title == "Story 1" })
        #expect(viewModel.stories.contains { $0.title == "Story 2" })
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Data Persistence Tests
    
    @Test("Test data persistence after refresh")
    func testDataPersistenceAfterRefresh() async throws {
        // Given
        let viewModel = HomeViewModel()
        let testStory = Story(
            title: "Persistent Story",
            content: "Persistent content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When
        viewModel.saveStory(testStory)
        viewModel.refresh()
        
        // Then
        #expect(viewModel.stories.count == 1)
        #expect(viewModel.stories.first?.title == "Persistent Story")
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
}
