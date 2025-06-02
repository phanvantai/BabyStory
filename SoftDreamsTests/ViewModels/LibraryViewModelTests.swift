//
//  LibraryViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct LibraryViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test("Test LibraryViewModel initialization")
    func testLibraryViewModelInitialization() async throws {
        // Clear any existing data
        try? StorageManager.shared.clearAllData()
        
        // When
        let viewModel = LibraryViewModel()
        
        // Then
        #expect(viewModel.stories.isEmpty)
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test LibraryViewModel initialization with existing stories")
    func testInitializationWithExistingStories() async throws {
        // Given
        let testStory = Story(
            title: "Test Story",
            content: "Test content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([testStory])
        
        // When
        let viewModel = LibraryViewModel()
        
        // Then
        #expect(viewModel.stories.count == 1)
        #expect(viewModel.stories.first?.title == "Test Story")
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Load Stories Tests
    
    @Test("Test loadStories with empty storage")
    func testLoadStoriesWithEmptyStorage() async throws {
        // Given
        let viewModel = LibraryViewModel()
        try? StorageManager.shared.clearAllData()
        
        // When
        viewModel.loadStories()
        
        // Then
        #expect(viewModel.stories.isEmpty)
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test loadStories with multiple stories")
    func testLoadStoriesWithMultipleStories() async throws {
        // Given
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
        
        try StorageManager.shared.saveStories([story1, story2])
        let viewModel = LibraryViewModel()
        
        // When
        viewModel.loadStories()
        
        // Then
        #expect(viewModel.stories.count == 2)
        #expect(viewModel.stories.contains { $0.title == "Story 1" })
        #expect(viewModel.stories.contains { $0.title == "Story 2" })
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Toggle Favorite Tests
    
    @Test("Test toggleFavorite makes story favorite")
    func testToggleFavoriteMakesStoryFavorite() async throws {
        // Given
        let story = Story(
            title: "Test Story",
            content: "Test content",
            isFavorite: false,
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([story])
        let viewModel = LibraryViewModel()
        
        // When
        viewModel.toggleFavorite(for: story)
        
        // Then
        let updatedStory = viewModel.stories.first { $0.id == story.id }
        #expect(updatedStory?.isFavorite == true)
        #expect(viewModel.error == nil)
        
        // Verify persistence
        let savedStories = try StorageManager.shared.loadStories()
        let savedStory = savedStories.first { $0.id == story.id }
        #expect(savedStory?.isFavorite == true)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test toggleFavorite removes favorite status")
    func testToggleFavoriteRemovesFavoriteStatus() async throws {
        // Given
        let story = Story(
            title: "Test Story",
            content: "Test content",
            isFavorite: true,
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([story])
        let viewModel = LibraryViewModel()
        
        // When
        viewModel.toggleFavorite(for: story)
        
        // Then
        let updatedStory = viewModel.stories.first { $0.id == story.id }
        #expect(updatedStory?.isFavorite == false)
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test toggleFavorite with non-existent story")
    func testToggleFavoriteWithNonExistentStory() async throws {
        // Given
        let existingStory = Story(
            title: "Existing Story",
            content: "Existing content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let nonExistentStory = Story(
            title: "Non-existent Story",
            content: "Non-existent content",
            theme: "Magic",
            length: .medium,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([existingStory])
        let viewModel = LibraryViewModel()
        
        // When
        viewModel.toggleFavorite(for: nonExistentStory)
        
        // Then
        #expect(viewModel.stories.count == 1)
        #expect(viewModel.stories.first?.title == "Existing Story")
        // Should not modify existing story
        #expect(viewModel.stories.first?.isFavorite == false)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Delete Story Tests
    
    @Test("Test deleteStory removes story")
    func testDeleteStoryRemovesStory() async throws {
        // Given
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
        
        try StorageManager.shared.saveStories([story1, story2])
        let viewModel = LibraryViewModel()
        
        // When
        viewModel.deleteStory(story1)
        
        // Then
        #expect(viewModel.stories.count == 1)
        #expect(viewModel.stories.first?.title == "Story 2")
        #expect(viewModel.error == nil)
        
        // Verify persistence
        let savedStories = try StorageManager.shared.loadStories()
        #expect(savedStories.count == 1)
        #expect(savedStories.first?.title == "Story 2")
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test deleteStory with non-existent story")
    func testDeleteStoryWithNonExistentStory() async throws {
        // Given
        let existingStory = Story(
            title: "Existing Story",
            content: "Existing content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let nonExistentStory = Story(
            title: "Non-existent Story",
            content: "Non-existent content",
            theme: "Magic",
            length: .medium,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([existingStory])
        let viewModel = LibraryViewModel()
        
        // When
        viewModel.deleteStory(nonExistentStory)
        
        // Then
        #expect(viewModel.stories.count == 1)
        #expect(viewModel.stories.first?.title == "Existing Story")
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Save Story Tests
    
    @Test("Test saveStory adds new story")
    func testSaveStoryAddsNewStory() async throws {
        // Given
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
        
        try StorageManager.shared.saveStories([existingStory])
        let viewModel = LibraryViewModel()
        
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
    
    @Test("Test saveStory updates existing story")
    func testSaveStoryUpdatesExistingStory() async throws {
        // Given
        let originalStory = Story(
            title: "Original Title",
            content: "Original content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([originalStory])
        let viewModel = LibraryViewModel()
        
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
        viewModel.saveStory(updatedStory)
        
        // Then
        let savedStory = viewModel.stories.first { $0.id == originalStory.id }
        #expect(savedStory?.title == "Updated Title")
        #expect(savedStory?.content == "Updated content")
        #expect(viewModel.error == nil)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Computed Properties Tests
    
    @Test("Test favoriteStories computed property")
    func testFavoriteStories() async throws {
        // Given
        let favoriteStory = Story(
            title: "Favorite Story",
            content: "Favorite content",
            isFavorite: true,
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let normalStory = Story(
            title: "Normal Story",
            content: "Normal content",
            isFavorite: false,
            theme: "Magic",
            length: .medium,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([favoriteStory, normalStory])
        let viewModel = LibraryViewModel()
        
        // When
        let favorites = viewModel.favoriteStories
        
        // Then
        #expect(favorites.count == 1)
        #expect(favorites.first?.title == "Favorite Story")
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    @Test("Test favoriteStories with no favorites")
    func testFavoriteStoriesWithNoFavorites() async throws {
        // Given
        let story1 = Story(
            title: "Story 1",
            content: "Content 1",
            isFavorite: false,
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        let story2 = Story(
            title: "Story 2",
            content: "Content 2",
            isFavorite: false,
            theme: "Magic",
            length: .medium,
            ageRange: .toddler
        )
        
        try StorageManager.shared.saveStories([story1, story2])
        let viewModel = LibraryViewModel()
        
        // When
        let favorites = viewModel.favoriteStories
        
        // Then
        #expect(favorites.isEmpty)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test error handling in toggleFavorite")
    func testErrorHandlingInToggleFavorite() async throws {
        // Given
        let viewModel = LibraryViewModel()
        let story = Story(
            title: "Test Story",
            content: "Test content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        // When calling with non-existent story
        viewModel.toggleFavorite(for: story)
        
        // Then
        // Should handle gracefully (no crash)
        // Error handling depends on implementation
    }
    
    // MARK: - Data Consistency Tests
    
    @Test("Test data consistency after operations")
    func testDataConsistencyAfterOperations() async throws {
        // Given
        let story = Story(
            title: "Test Story",
            content: "Test content",
            theme: "Adventure",
            length: .short,
            ageRange: .toddler
        )
        
        let viewModel = LibraryViewModel()
        
        // When performing multiple operations
        viewModel.saveStory(story)
        viewModel.toggleFavorite(for: story)
        viewModel.loadStories()
        
        // Then
        #expect(viewModel.stories.count == 1)
        let savedStory = viewModel.stories.first
        #expect(savedStory?.title == "Test Story")
        #expect(savedStory?.isFavorite == true)
        
        // Cleanup
        try? StorageManager.shared.clearAllData()
    }
}
