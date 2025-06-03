//
//  MockStoryService.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
@testable import SoftDreams

// MARK: - Mock Story Service for Testing
class MockStoryService: StoryServiceProtocol {
    var savedStories: [Story] = []
    var shouldFailSave = false
    var shouldFailLoad = false
    
    func saveStories(_ stories: [Story]) throws {
        if shouldFailSave {
            throw AppError.storySaveFailed
        }
        savedStories = stories
    }
    
    func loadStories() throws -> [Story] {
        if shouldFailLoad || shouldFailSave {
            throw AppError.dataCorruption
        }
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
        if shouldFailLoad || shouldFailSave {
            throw AppError.dataCorruption
        }
        return savedStories.count
    }
}
