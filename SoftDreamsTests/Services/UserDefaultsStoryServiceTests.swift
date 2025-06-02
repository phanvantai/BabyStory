import Testing
import Foundation
@testable import SoftDreams

struct UserDefaultsStoryServiceTests {
    
    init() {
        // Clean up before each test
        UserDefaults.standard.removeObject(forKey: "saved_stories")
    }
    
    deinit {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "saved_stories")
    }
    
    @Test("Save and load stories successfully")
    func testSaveAndLoadStories() throws {
        let service = UserDefaultsStoryService()
        let stories = [
            Story(
                id: UUID(),
                title: "First Story",
                content: "Once upon a time...",
                date: Date(),
                isFavorite: false,
                theme: "Adventure",
                length: .medium,
                characters: ["hero"],
                ageRange: .toddler,
                readingTime: 5,
                tags: ["adventure", "fun"]
            ),
            Story(
                id: UUID(),
                title: "Second Story",
                content: "In a magical land...",
                date: Date(),
                isFavorite: true,
                theme: "Magic",
                length: .long,
                characters: ["wizard", "dragon"],
                ageRange: .preschooler,
                readingTime: 8,
                tags: ["magic", "fantasy"]
            )
        ]
        
        try service.saveStories(stories)
        let loadedStories = try service.loadStories()
        
        #expect(loadedStories.count == 2)
        #expect(loadedStories[0].title == "First Story")
        #expect(loadedStories[1].title == "Second Story")
        #expect(loadedStories[1].isFavorite == true)
    }
    
    @Test("Load stories when none exist")
    func testLoadStoriesWhenNoneExist() throws {
        let service = UserDefaultsStoryService()
        
        let stories = try service.loadStories()
        
        #expect(stories.isEmpty)
    }
    
    @Test("Save single story")
    func testSaveSingleStory() throws {
        let service = UserDefaultsStoryService()
        let story = Story(
            id: UUID(),
            title: "Single Story",
            content: "A standalone tale...",
            date: Date(),
            isFavorite: false,
            theme: "Friendship",
            length: .short,
            characters: ["friend"],
            ageRange: .infant,
            readingTime: 3,
            tags: ["friendship"]
        )
        
        try service.saveStory(story)
        let loadedStories = try service.loadStories()
        
        #expect(loadedStories.count == 1)
        #expect(loadedStories[0].title == "Single Story")
        #expect(loadedStories[0].id == story.id)
    }
    
    @Test("Save story replaces existing with same ID")
    func testSaveStoryReplacesExisting() throws {
        let service = UserDefaultsStoryService()
        let storyId = UUID()
        
        let originalStory = Story(
            id: storyId,
            title: "Original Title",
            content: "Original content",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .medium,
            characters: [],
            ageRange: .toddler,
            readingTime: 5,
            tags: []
        )
        
        try service.saveStory(originalStory)
        
        let updatedStory = Story(
            id: storyId, // Same ID
            title: "Updated Title",
            content: "Updated content",
            date: Date(),
            isFavorite: true,
            theme: "Magic",
            length: .long,
            characters: ["wizard"],
            ageRange: .preschooler,
            readingTime: 8,
            tags: ["magic"]
        )
        
        try service.saveStory(updatedStory)
        let loadedStories = try service.loadStories()
        
        #expect(loadedStories.count == 1)
        #expect(loadedStories[0].title == "Updated Title")
        #expect(loadedStories[0].isFavorite == true)
        #expect(loadedStories[0].theme == "Magic")
    }
    
    @Test("Delete story by ID")
    func testDeleteStoryById() throws {
        let service = UserDefaultsStoryService()
        let story1 = Story(
            id: UUID(),
            title: "Keep This",
            content: "Content to keep",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .medium,
            characters: [],
            ageRange: .toddler,
            readingTime: 5,
            tags: []
        )
        
        let story2 = Story(
            id: UUID(),
            title: "Delete This",
            content: "Content to delete",
            date: Date(),
            isFavorite: false,
            theme: "Magic",
            length: .short,
            characters: [],
            ageRange: .infant,
            readingTime: 3,
            tags: []
        )
        
        try service.saveStories([story1, story2])
        
        try service.deleteStory(withId: story2.id.uuidString)
        let loadedStories = try service.loadStories()
        
        #expect(loadedStories.count == 1)
        #expect(loadedStories[0].title == "Keep This")
        #expect(loadedStories[0].id == story1.id)
    }
    
    @Test("Delete non-existent story does not crash")
    func testDeleteNonExistentStory() throws {
        let service = UserDefaultsStoryService()
        let story = Story(
            id: UUID(),
            title: "Existing Story",
            content: "Content",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .medium,
            characters: [],
            ageRange: .toddler,
            readingTime: 5,
            tags: []
        )
        
        try service.saveStory(story)
        
        // Try to delete a non-existent story
        try service.deleteStory(withId: UUID().uuidString)
        
        let loadedStories = try service.loadStories()
        #expect(loadedStories.count == 1) // Original story should still exist
    }
    
    @Test("Update existing story")
    func testUpdateStory() throws {
        let service = UserDefaultsStoryService()
        let originalStory = Story(
            id: UUID(),
            title: "Original",
            content: "Original content",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .medium,
            characters: [],
            ageRange: .toddler,
            readingTime: 5,
            tags: []
        )
        
        try service.saveStory(originalStory)
        
        let updatedStory = Story(
            id: originalStory.id,
            title: "Updated",
            content: "Updated content",
            date: originalStory.date,
            isFavorite: true, // Changed
            theme: originalStory.theme,
            length: originalStory.length,
            characters: originalStory.characters,
            ageRange: originalStory.ageRange,
            readingTime: originalStory.readingTime,
            tags: originalStory.tags
        )
        
        try service.updateStory(updatedStory)
        let loadedStories = try service.loadStories()
        
        #expect(loadedStories.count == 1)
        #expect(loadedStories[0].title == "Updated")
        #expect(loadedStories[0].isFavorite == true)
        #expect(loadedStories[0].id == originalStory.id)
    }
    
    @Test("Get story by ID")
    func testGetStoryById() throws {
        let service = UserDefaultsStoryService()
        let story1 = Story(
            id: UUID(),
            title: "First Story",
            content: "First content",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .medium,
            characters: [],
            ageRange: .toddler,
            readingTime: 5,
            tags: []
        )
        
        let story2 = Story(
            id: UUID(),
            title: "Second Story",
            content: "Second content",
            date: Date(),
            isFavorite: true,
            theme: "Magic",
            length: .long,
            characters: [],
            ageRange: .preschooler,
            readingTime: 8,
            tags: []
        )
        
        try service.saveStories([story1, story2])
        
        let foundStory = try service.getStory(withId: story2.id.uuidString)
        let notFoundStory = try service.getStory(withId: UUID().uuidString)
        
        #expect(foundStory != nil)
        #expect(foundStory?.title == "Second Story")
        #expect(foundStory?.isFavorite == true)
        #expect(notFoundStory == nil)
    }
    
    @Test("Get story count")
    func testGetStoryCount() throws {
        let service = UserDefaultsStoryService()
        
        #expect(try service.getStoryCount() == 0)
        
        let stories = [
            Story(
                id: UUID(),
                title: "Story 1",
                content: "Content 1",
                date: Date(),
                isFavorite: false,
                theme: "Adventure",
                length: .short,
                characters: [],
                ageRange: .toddler,
                readingTime: 3,
                tags: []
            ),
            Story(
                id: UUID(),
                title: "Story 2",
                content: "Content 2",
                date: Date(),
                isFavorite: true,
                theme: "Magic",
                length: .medium,
                characters: [],
                ageRange: .infant,
                readingTime: 5,
                tags: []
            )
        ]
        
        try service.saveStories(stories)
        #expect(try service.getStoryCount() == 2)
        
        try service.deleteStory(withId: stories[0].id.uuidString)
        #expect(try service.getStoryCount() == 1)
    }
    
    @Test("Complex story data integrity")
    func testComplexStoryDataIntegrity() throws {
        let service = UserDefaultsStoryService()
        let calendar = Calendar.current
        let storyDate = calendar.date(from: DateComponents(year: 2025, month: 6, day: 1))!
        
        let story = Story(
            id: UUID(),
            title: "Complex Story with Unicode 🌟",
            content: """
            This is a multi-line story content with special characters:
            - Unicode emojis: 🦄🐉🌈
            - Accented characters: café, naïve, résumé
            - Quotes: "Hello," she said. 'How are you?'
            - Newlines and formatting
            
            The end.
            """,
            date: storyDate,
            isFavorite: true,
            theme: "Fantasy & Adventure",
            length: .long,
            characters: ["Princess 👸", "Dragon 🐉", "Knight ⚔️"],
            ageRange: .preschooler,
            readingTime: 12,
            tags: ["fantasy", "adventure", "unicode-test", "multi-line"]
        )
        
        try service.saveStory(story)
        let loadedStories = try service.loadStories()
        
        #expect(loadedStories.count == 1)
        let loadedStory = loadedStories[0]
        
        #expect(loadedStory.title == story.title)
        #expect(loadedStory.content == story.content)
        #expect(loadedStory.characters == story.characters)
        #expect(loadedStory.tags == story.tags)
        #expect(loadedStory.theme == story.theme)
        #expect(calendar.isDate(loadedStory.date, inSameDayAs: story.date))
    }
    
    @Test("Error handling for corrupted data")
    func testErrorHandlingCorruptedData() {
        let service = UserDefaultsStoryService()
        
        // Manually set corrupted data
        UserDefaults.standard.set("corrupted data", forKey: "saved_stories")
        
        #expect(throws: AppError.self) {
            try service.loadStories()
        }
    }
    
    @Test("Multiple operations sequence")
    func testMultipleOperationsSequence() throws {
        let service = UserDefaultsStoryService()
        
        // Start with empty
        #expect(try service.getStoryCount() == 0)
        
        // Add first story
        let story1 = Story(
            id: UUID(),
            title: "First",
            content: "First content",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .short,
            characters: [],
            ageRange: .toddler,
            readingTime: 3,
            tags: []
        )
        try service.saveStory(story1)
        #expect(try service.getStoryCount() == 1)
        
        // Add second story
        let story2 = Story(
            id: UUID(),
            title: "Second",
            content: "Second content",
            date: Date(),
            isFavorite: true,
            theme: "Magic",
            length: .medium,
            characters: [],
            ageRange: .infant,
            readingTime: 5,
            tags: []
        )
        try service.saveStory(story2)
        #expect(try service.getStoryCount() == 2)
        
        // Update first story
        let updatedStory1 = Story(
            id: story1.id,
            title: "First Updated",
            content: story1.content,
            date: story1.date,
            isFavorite: true,
            theme: story1.theme,
            length: story1.length,
            characters: story1.characters,
            ageRange: story1.ageRange,
            readingTime: story1.readingTime,
            tags: story1.tags
        )
        try service.updateStory(updatedStory1)
        #expect(try service.getStoryCount() == 2) // Count unchanged
        
        // Verify update
        let foundStory = try service.getStory(withId: story1.id.uuidString)
        #expect(foundStory?.title == "First Updated")
        #expect(foundStory?.isFavorite == true)
        
        // Delete one story
        try service.deleteStory(withId: story2.id.uuidString)
        #expect(try service.getStoryCount() == 1)
        
        // Verify only first story remains
        let remainingStories = try service.loadStories()
        #expect(remainingStories.count == 1)
        #expect(remainingStories[0].title == "First Updated")
    }
}
