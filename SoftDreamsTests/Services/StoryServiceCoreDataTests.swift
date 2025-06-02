//
//  StoryServiceCoreDataTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import CoreData
@testable import SoftDreams

@MainActor
class StoryServiceTests {
    
    private var storyService: StoryService!
    private var context: NSManagedObjectContext!
    
    init() {
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "SoftDreams")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        context = container.viewContext
        storyService = StoryService(context: context)
    }
    
    @Test
    func testSaveStory_WhenValidStory_ShouldSaveSuccessfully() async throws {
        // Given
        let story = Story(
            id: "test-id",
            title: "Test Story",
            content: "Once upon a time...",
            characterName: "Alice",
            theme: "Adventure",
            storyLength: .medium,
            createdAt: Date(),
            isFavorite: false
        )
        
        // When
        try await storyService.saveStory(story)
        
        // Then
        let savedStories = try await storyService.fetchAllStories()
        #expect(savedStories.count == 1)
        #expect(savedStories.first?.title == "Test Story")
    }
    
    @Test
    func testFetchAllStories_WhenStoriesExist_ShouldReturnAllStories() async throws {
        // Given
        let story1 = Story(id: "1", title: "Story 1", content: "Content 1", characterName: "Alice", theme: "Adventure", storyLength: .short, createdAt: Date(), isFavorite: false)
        let story2 = Story(id: "2", title: "Story 2", content: "Content 2", characterName: "Bob", theme: "Fantasy", storyLength: .long, createdAt: Date(), isFavorite: true)
        
        try await storyService.saveStory(story1)
        try await storyService.saveStory(story2)
        
        // When
        let stories = try await storyService.fetchAllStories()
        
        // Then
        #expect(stories.count == 2)
        #expect(stories.contains { $0.title == "Story 1" })
        #expect(stories.contains { $0.title == "Story 2" })
    }
    
    @Test
    func testDeleteStory_WhenStoryExists_ShouldRemoveStory() async throws {
        // Given
        let story = Story(id: "delete-test", title: "To Delete", content: "Content", characterName: "Alice", theme: "Adventure", storyLength: .medium, createdAt: Date(), isFavorite: false)
        try await storyService.saveStory(story)
        
        // When
        try await storyService.deleteStory(withId: "delete-test")
        
        // Then
        let stories = try await storyService.fetchAllStories()
        #expect(stories.isEmpty)
    }
    
    @Test
    func testToggleFavorite_WhenStoryExists_ShouldUpdateFavoriteStatus() async throws {
        // Given
        let story = Story(id: "favorite-test", title: "Test", content: "Content", characterName: "Alice", theme: "Adventure", storyLength: .medium, createdAt: Date(), isFavorite: false)
        try await storyService.saveStory(story)
        
        // When
        try await storyService.toggleFavorite(storyId: "favorite-test")
        
        // Then
        let updatedStories = try await storyService.fetchAllStories()
        let updatedStory = updatedStories.first { $0.id == "favorite-test" }
        #expect(updatedStory?.isFavorite == true)
    }
}
