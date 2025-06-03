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
