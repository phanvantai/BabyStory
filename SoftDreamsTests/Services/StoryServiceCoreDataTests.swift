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
            id: UUID(),
            title: "Test Story",
            content: "Once upon a time...",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .medium,
            characters: ["Alice"],
            ageRange: .toddler
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
        let story1 = Story(id: UUID(), title: "Story 1", content: "Content 1", theme: "Adventure", length: .short, ageRange: .toddler)
      let story2 = Story(id: UUID(), title: "Story 2", content: "Content 2", isFavorite: true, theme: "Fantasy", length: .long, ageRange: .toddler)
        
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
        let storyId = UUID()
        let story = Story(id: storyId, title: "To Delete", content: "Content", theme: "Adventure", length: .medium, ageRange: .toddler)
        try await storyService.saveStory(story)
        
        // When
        try await storyService.deleteStory(withId: storyId.uuidString)
        
        // Then
        let stories = try await storyService.fetchAllStories()
        #expect(stories.isEmpty)
    }
    
    @Test
    func testToggleFavorite_WhenStoryExists_ShouldUpdateFavoriteStatus() async throws {
        // Given
        let storyId = UUID()
      let story = Story(id: storyId, title: "Test", content: "Content", isFavorite: false, theme: "Adventure", length: .medium, ageRange: .toddler)
        try await storyService.saveStory(story)
        
        // When
        try await storyService.toggleFavorite(storyId: storyId.uuidString)
        
        // Then
        let updatedStories = try await storyService.fetchAllStories()
        let updatedStory = updatedStories.first { $0.id == storyId }
        #expect(updatedStory?.isFavorite == true)
    }
}
