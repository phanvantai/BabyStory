//
//  HomeViewModelTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct HomeViewModelTests {
    
    // MARK: - Test Dependencies
    
    private func createTestProfile() -> UserProfile {
        UserProfile(
            name: "Test Child",
            babyStage: .toddler,
            interests: ["Adventure", "Animals"],
            storyTime: Date(),
            language: .english
        )
    }
    
    private func createTestStory() -> Story {
        Story(
            title: "Test Story",
            content: "Once upon a time...",
            theme: "Adventure",
            length: .medium,
            ageRange: .toddler
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("Test HomeViewModel initialization with dependency injection")
    func testHomeViewModelInitializationWithDependencyInjection() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        // When
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // Then
        #expect(viewModel.profile == nil, "Profile should be nil on initialization")
        #expect(viewModel.stories.isEmpty, "Stories should be empty on initialization")
        #expect(viewModel.error == nil, "Error should be nil on initialization")
    }
    
    // MARK: - Refresh Tests
    
    @Test("Test refresh with valid profile and stories loads successfully")
    func testRefreshWithValidProfileAndStoriesLoadsSuccessfully() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        let testProfile = createTestProfile()
        let testStory = createTestStory()
        
        mockUserProfileService.savedProfile = testProfile
        mockStoryService.savedStories = [testStory]
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When
        viewModel.refresh()
        
        // Then
        #expect(viewModel.profile?.name == testProfile.name, "Profile should be loaded correctly")
        #expect(viewModel.stories.count == 1, "Stories should be loaded correctly")
        #expect(viewModel.stories.first?.title == testStory.title, "Story title should match")
        #expect(viewModel.error == nil, "Error should be nil on successful refresh")
    }
    
    @Test("Test refresh when profile service fails sets error")
    func testRefreshWhenProfileServiceFailsSetsError() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        mockUserProfileService.shouldFailLoad = true
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When
        viewModel.refresh()
        
        // Then
        #expect(viewModel.profile == nil, "Profile should be nil when loading fails")
        #expect(viewModel.error != nil, "Error should be set when profile loading fails")
    }
    
    @Test("Test refresh when story service fails sets error")
    func testRefreshWhenStoryServiceFailsSetsError() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        let testProfile = createTestProfile()
        
        mockUserProfileService.savedProfile = testProfile
        mockStoryService.shouldFailSave = true // This will make loadStories fail
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When
        viewModel.refresh()
        
        // Then
        #expect(viewModel.profile?.name == testProfile.name, "Profile should still be loaded")
        #expect(viewModel.stories.isEmpty, "Stories should be empty when loading fails")
        #expect(viewModel.error != nil, "Error should be set when story loading fails")
    }
    
    // MARK: - Convenience Properties Tests
    
    @Test("Test hasCompletedOnboarding returns true when profile exists")
    func testHasCompletedOnboardingReturnsTrueWhenProfileExists() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        let testProfile = createTestProfile()
        
        mockUserProfileService.savedProfile = testProfile
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When & Then
        #expect(viewModel.hasCompletedOnboarding == true, "Should return true when profile exists")
    }
    
    @Test("Test hasCompletedOnboarding returns false when no profile exists")
    func testHasCompletedOnboardingReturnsFalseWhenNoProfileExists() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        // No profile set in mock service
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When & Then
        #expect(viewModel.hasCompletedOnboarding == false, "Should return false when no profile exists")
    }
    
    @Test("Test hasCompletedOnboarding returns false when profile service fails")
    func testHasCompletedOnboardingReturnsFalseWhenProfileServiceFails() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        mockUserProfileService.shouldFailLoad = true
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When & Then
        #expect(viewModel.hasCompletedOnboarding == false, "Should return false when profile service fails")
    }
    
    @Test("Test totalStoriesCount returns correct count")
    func testTotalStoriesCountReturnsCorrectCount() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        let testStories = [createTestStory(), createTestStory()]
        
        mockStoryService.savedStories = testStories
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When & Then
        #expect(viewModel.totalStoriesCount == 2, "Should return correct story count")
    }
    
    @Test("Test totalStoriesCount returns zero when story service fails")
    func testTotalStoriesCountReturnsZeroWhenStoryServiceFails() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        mockStoryService.shouldFailSave = true // This will make loadStories fail
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When & Then
        #expect(viewModel.totalStoriesCount == 0, "Should return zero when story service fails")
    }
    
    // MARK: - getStoriesCreatedToday Tests
    
    @Test("Test getStoriesCreatedToday returns stories from today")
    func testGetStoriesCreatedTodayReturnsStoriesFromToday() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        let todayStory = Story(
            title: "Today's Story",
            content: "Today's content",
            date: Date(),
            theme: "Adventure",
            length: .medium,
            ageRange: .toddler
        )
        
        let yesterdayStory = Story(
            title: "Yesterday's Story",
            content: "Yesterday's content",
            date: Date().addingTimeInterval(-86400), // 24 hours ago
            theme: "Adventure",
            length: .medium,
            ageRange: .toddler
        )
        
        mockStoryService.savedStories = [todayStory, yesterdayStory]
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When
        let todaysStories = viewModel.getStoriesCreatedToday()
        
        // Then
        #expect(todaysStories.count == 1, "Should return only today's stories")
        #expect(todaysStories.first?.title == "Today's Story", "Should return the correct story")
    }
    
    @Test("Test getStoriesCreatedToday returns empty array when story service fails")
    func testGetStoriesCreatedTodayReturnsEmptyArrayWhenStoryServiceFails() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        mockStoryService.shouldFailSave = true // This will make loadStories fail
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        
        // When
        let todaysStories = viewModel.getStoriesCreatedToday()
        
        // Then
        #expect(todaysStories.isEmpty, "Should return empty array when service fails")
        #expect(viewModel.error != nil, "Should set error when service fails")
    }
    
    // MARK: - Story Generation Tests
    
    @Test("Test generateTodaysStory with valid profile generates story")
    func testGenerateTodaysStoryWithValidProfileGeneratesStory() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        let testProfile = createTestProfile()
        
        mockUserProfileService.savedProfile = testProfile
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        viewModel.profile = testProfile // Set profile directly for this test
        
        // Create a mock story generation view model
        let mockStoryGenService = MockStoryGenerationService(mockDelay: 0.1) // Fast for tests
        let storyGenViewModel = StoryGenerationViewModel(
            storyGenerationService: mockStoryGenService,
            storyService: mockStoryService
        )
        
        var completionResult: Story?
        
        // When
        await withCheckedContinuation { continuation in
            viewModel.generateTodaysStory(using: storyGenViewModel) { story in
                completionResult = story
                continuation.resume()
            }
        }
        
        // Then
        #expect(completionResult != nil, "Should generate a story")
        #expect(viewModel.error == nil, "Should not have error on successful generation")
    }
    
    @Test("Test generateTodaysStory with no profile sets error")
    func testGenerateTodaysStoryWithNoProfileSetsError() async throws {
        // Given
        let mockUserProfileService = MockUserProfileService()
        let mockStoryService = MockStoryService()
        
        let viewModel = HomeViewModel(
            userProfileService: mockUserProfileService,
            storyService: mockStoryService
        )
        // Don't set profile - it should be nil
        
        let mockStoryGenService = MockStoryGenerationService(mockDelay: 0.1) // Fast for tests
        let storyGenViewModel = StoryGenerationViewModel(
            storyGenerationService: mockStoryGenService,
            storyService: mockStoryService
        )
        
        var completionResult: Story?
        
        // When
        await withCheckedContinuation { continuation in
            viewModel.generateTodaysStory(using: storyGenViewModel) { story in
                completionResult = story
                continuation.resume()
            }
        }
        
        // Then
        #expect(completionResult == nil, "Should not generate story without profile")
        #expect(viewModel.error == .invalidProfile, "Should set invalid profile error")
    }
}
