//
//  MockStoryGenerationService.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
@testable import SoftDreams

// MARK: - Mock Story Generation Service for Testing
class MockStoryGenerationService: StoryGenerationServiceProtocol {
    var shouldFailGeneration = false
    var mockDelay: TimeInterval
    var generatedStoryTitle = "Mock Story Title"
    var generatedStoryContent = "Once upon a time, in a mock test..."
    
    init(mockDelay: TimeInterval = 0.1) {
        self.mockDelay = mockDelay
    }
    
    func generateStory(for profile: UserProfile, with options: StoryOptions) async throws -> Story {
        if shouldFailGeneration {
            throw StoryGenerationError.generationFailed
        }
        
        // Simulate generation delay
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        return Story(
            title: generatedStoryTitle,
            content: generatedStoryContent,
            theme: options.theme,
            length: options.length,
            ageRange: profile.babyStage
        )
    }
    
    func generateDailyStory(for profile: UserProfile) async throws -> Story {
        if shouldFailGeneration {
            throw StoryGenerationError.generationFailed
        }
        
        // Simulate generation delay
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        return Story(
            title: "Daily \(generatedStoryTitle)",
            content: generatedStoryContent,
            theme: "Adventure",
            length: .medium,
            ageRange: profile.babyStage
        )
    }
    
    func canGenerateStory(for profile: UserProfile, with options: StoryOptions) -> Bool {
        return !shouldFailGeneration
    }
    
    func getSuggestedThemes(for profile: UserProfile) -> [String] {
        return ["Adventure", "Animals", "Magic", "Friendship"]
    }
    
    func getEstimatedGenerationTime(for options: StoryOptions) -> TimeInterval {
        return mockDelay
    }
}
