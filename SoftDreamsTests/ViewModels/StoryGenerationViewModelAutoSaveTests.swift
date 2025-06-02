//
//  StoryGenerationViewModelAutoSaveTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Foundation
import Testing
@testable import SoftDreams

@MainActor
class StoryGenerationViewModelAutoSaveTests {
    
    private var viewModel: StoryGenerationViewModel!
    private var mockStoryService: MockStoryService!
    
    init() {
        mockStoryService = MockStoryService()
        viewModel = StoryGenerationViewModel(storyService: mockStoryService)
    }
    
    @Test
    func testGenerateStory_WhenAutoSaveEnabled_ShouldAutomaticallySaveToLibrary() async throws {
        // Given
        let profile = UserProfile.mockProfile
        let options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        viewModel.autoSaveToLibrary = true
        
        // When
        await viewModel.generateStory(profile: profile, options: options)
        
        // Then
        #expect(viewModel.generatedStory != nil)
        #expect(viewModel.error == nil)
        #expect(mockStoryService.savedStories.count == 1)
        #expect(mockStoryService.savedStories.first?.title == viewModel.generatedStory?.title)
    }
    
    @Test
    func testGenerateStory_WhenAutoSaveDisabled_ShouldNotSaveToLibrary() async throws {
        // Given
        let profile = UserProfile.mockProfile
        let options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        viewModel.autoSaveToLibrary = false
        
        // When
        await viewModel.generateStory(profile: profile, options: options)
        
        // Then
        #expect(viewModel.generatedStory != nil)
        #expect(viewModel.error == nil)
        #expect(mockStoryService.savedStories.isEmpty)
    }
    
    @Test
    func testGenerateStory_WhenAutoSaveFailsWithStorageError_ShouldSetError() async throws {
        // Given
        let profile = UserProfile.mockProfile
        let options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        viewModel.autoSaveToLibrary = true
        mockStoryService.shouldFailSave = true
        
        // When
        await viewModel.generateStory(profile: profile, options: options)
        
        // Then
        #expect(viewModel.generatedStory != nil) // Story should still be generated
        #expect(viewModel.error != nil) // But error should be set for save failure
        #expect(mockStoryService.savedStories.isEmpty) // No stories should be saved
    }
    
    @Test
    func testGenerateDailyStory_WhenAutoSaveEnabled_ShouldAutomaticallySaveToLibrary() async throws {
        // Given
        let profile = UserProfile.mockProfile
        viewModel.autoSaveToLibrary = true
        
        // When
        await viewModel.generateDailyStory(profile: profile)
        
        // Then
        #expect(viewModel.generatedStory != nil)
        #expect(viewModel.error == nil)
        #expect(mockStoryService.savedStories.count == 1)
        #expect(mockStoryService.savedStories.first?.title == viewModel.generatedStory?.title)
    }
    
    @Test
    func testAutoSaveProperty_DefaultValue_ShouldBeTrue() {
        // Given & When
        let newViewModel = StoryGenerationViewModel(storyService: mockStoryService)
        
        // Then
        #expect(newViewModel.autoSaveToLibrary == true)
    }
}

// MARK: - Mock Story Service for Testing
class MockStoryService: StoryServiceProtocol {
    var savedStories: [Story] = []
    var shouldFailSave = false
    
    func saveStories(_ stories: [Story]) throws {
        if shouldFailSave {
            throw AppError.storySaveFailed
        }
        savedStories = stories
    }
    
    func loadStories() throws -> [Story] {
        return savedStories
    }
    
    func saveStory(_ story: Story) throws {
        if shouldFailSave {
            throw AppError.storySaveFailed
        }
        // Remove existing story with same ID if it exists
        savedStories.removeAll { $0.id == story.id }
        savedStories.append(story)
    }
    
    func deleteStory(withId id: String) throws {
        savedStories.removeAll { $0.id.uuidString == id }
    }
    
    func updateStory(_ story: Story) throws {
        try saveStory(story)
    }
    
    func getStory(withId id: String) throws -> Story? {
        return savedStories.first { $0.id.uuidString == id }
    }
    
    func getStoryCount() throws -> Int {
        return savedStories.count
    }
}

// MARK: - Mock UserProfile Extension
extension UserProfile {
    static var mockProfile: UserProfile {
        UserProfile(
            name: "Test Child",
            babyStage: .toddler,
            interests: ["Adventure", "Animals"],
            storyTime: Date(),
            language: .english
        )
    }
}
