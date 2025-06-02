import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct StoryGenerationViewModelTests {
    
    init() {
        // Clean up before each test
        StorageManager.shared.clearAllData()
    }
    
    deinit {
        // Clean up after each test
        StorageManager.shared.clearAllData()
    }
    
    @Test("Initialization sets up default state correctly")
    func testInitialization() {
        let viewModel = StoryGenerationViewModel()
        
        #expect(viewModel.options.length == .medium)
        #expect(viewModel.options.theme == "Adventure")
        #expect(viewModel.options.characters.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory == nil)
        #expect(viewModel.error == nil)
    }
    
    @Test("Initialization with custom service")
    func testInitializationWithCustomService() {
        let mockService = MockStoryGenerationService(mockDelay: 0.1)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        #expect(viewModel.options.length == .medium)
        #expect(viewModel.options.theme == "Adventure")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("Generate story successfully")
    func testGenerateStorySuccess() async {
        let mockService = MockStoryGenerationService(mockDelay: 0.1)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
            interests: ["dragons"],
            motherDueDate: nil
        )
        
        let options = StoryOptions(length: .short, theme: "Adventure", characters: ["dragon"])
        
        await viewModel.generateStory(profile: profile, options: options)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory != nil)
        #expect(viewModel.error == nil)
        #expect(viewModel.generatedStory?.title.isEmpty == false)
        #expect(viewModel.generatedStory?.content.isEmpty == false)
    }
    
    @Test("Generate story with nil options uses default")
    func testGenerateStoryWithNilOptions() async {
        let mockService = MockStoryGenerationService(mockDelay: 0.1)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .girl,
            birthDate: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
            interests: ["unicorns"],
            motherDueDate: nil
        )
        
        await viewModel.generateStory(profile: profile, options: nil)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory != nil)
        #expect(viewModel.error == nil)
    }
    
    @Test("Generate story with invalid profile")
    func testGenerateStoryWithInvalidProfile() async {
        let mockService = FailingStoryGenerationService(errorType: .invalidProfile)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "", // Invalid empty name
            gender: .boy,
            birthDate: Date(),
            interests: [],
            motherDueDate: nil
        )
        
        let options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        
        await viewModel.generateStory(profile: profile, options: options)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory == nil)
        #expect(viewModel.error == .invalidProfile)
    }
    
    @Test("Generate story with network error")
    func testGenerateStoryWithNetworkError() async {
        let mockService = FailingStoryGenerationService(errorType: .networkError)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Date(),
            interests: ["adventure"],
            motherDueDate: nil
        )
        
        let options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
        
        await viewModel.generateStory(profile: profile, options: options)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory == nil)
        #expect(viewModel.error == .networkUnavailable)
    }
    
    @Test("Generate story with service unavailable error")
    func testGenerateStoryWithServiceUnavailableError() async {
        let mockService = FailingStoryGenerationService(errorType: .serviceUnavailable)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .girl,
            birthDate: Date(),
            interests: ["magic"],
            motherDueDate: nil
        )
        
        let options = StoryOptions(length: .long, theme: "Magic", characters: ["fairy"])
        
        await viewModel.generateStory(profile: profile, options: options)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory == nil)
        #expect(viewModel.error == .networkUnavailable)
    }
    
    @Test("Generate daily story successfully")
    func testGenerateDailyStorySuccess() async {
        let mockService = MockStoryGenerationService(mockDelay: 0.1)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Daily Child",
            gender: .boy,
            birthDate: Calendar.current.date(byAdding: .year, value: -4, to: Date())!,
            interests: ["animals"],
            motherDueDate: nil
        )
        
        await viewModel.generateDailyStory(profile: profile)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory != nil)
        #expect(viewModel.error == nil)
        #expect(viewModel.generatedStory?.title.contains("Daily") == true ||
                viewModel.generatedStory?.title.isEmpty == false)
    }
    
    @Test("Generate daily story with error")
    func testGenerateDailyStoryWithError() async {
        let mockService = FailingStoryGenerationService(errorType: .generationFailed)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .girl,
            birthDate: Date(),
            interests: ["friendship"],
            motherDueDate: nil
        )
        
        await viewModel.generateDailyStory(profile: profile)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory == nil)
        #expect(viewModel.error == .storyGenerationFailed)
    }
    
    @Test("Loading state management during generation")
    func testLoadingStateManagement() async {
        let mockService = MockStoryGenerationService(mockDelay: 0.2)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Loading Test",
            gender: .boy,
            birthDate: Date(),
            interests: ["testing"],
            motherDueDate: nil
        )
        
        // Start generation
        let generationTask = Task {
            await viewModel.generateStory(profile: profile, options: nil)
        }
        
        // Give it a moment to set loading state
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        #expect(viewModel.isLoading == true)
        #expect(viewModel.isGenerating == true)
        #expect(viewModel.error == nil)
        
        // Wait for completion
        await generationTask.value
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.generatedStory != nil)
    }
    
    @Test("Error mapping for all StoryGenerationError cases")
    func testErrorMappingInvalidOptions() async {
        let mockService = FailingStoryGenerationService(errorType: .invalidOptions)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Date(),
            interests: [],
            motherDueDate: nil
        )
        
        await viewModel.generateStory(profile: profile, options: nil)
        
        #expect(viewModel.error == .invalidStoryOptions)
    }
    
    @Test("Error mapping for quota exceeded")
    func testErrorMappingQuotaExceeded() async {
        let mockService = FailingStoryGenerationService(errorType: .quotaExceeded)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .girl,
            birthDate: Date(),
            interests: ["stories"],
            motherDueDate: nil
        )
        
        await viewModel.generateStory(profile: profile, options: nil)
        
        #expect(viewModel.error == .storyGenerationFailed)
    }
    
    @Test("Error mapping for unexpected errors")
    func testErrorMappingUnexpectedError() async {
        let mockService = FailingStoryGenerationService(errorType: .customError)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Date(),
            interests: ["mystery"],
            motherDueDate: nil
        )
        
        await viewModel.generateStory(profile: profile, options: nil)
        
        #expect(viewModel.error == .storyGenerationFailed)
    }
    
    @Test("Multiple story generations")
    func testMultipleStoryGenerations() async {
        let mockService = MockStoryGenerationService(mockDelay: 0.1)
        let viewModel = StoryGenerationViewModel(storyGenerationService: mockService)
        
        let profile = UserProfile(
            name: "Multi Test",
            gender: .girl,
            birthDate: Date(),
            interests: ["adventures"],
            motherDueDate: nil
        )
        
        // First generation
        await viewModel.generateStory(profile: profile, options: nil)
        let firstStory = viewModel.generatedStory
        
        #expect(firstStory != nil)
        #expect(viewModel.error == nil)
        
        // Second generation with different options
        let newOptions = StoryOptions(length: .long, theme: "Friendship", characters: ["best friend"])
        await viewModel.generateStory(profile: profile, options: newOptions)
        let secondStory = viewModel.generatedStory
        
        #expect(secondStory != nil)
        #expect(viewModel.error == nil)
        #expect(firstStory?.id != secondStory?.id) // Different stories
    }
    
    @Test("Options property updates")
    func testOptionsPropertyUpdates() {
        let viewModel = StoryGenerationViewModel()
        
        #expect(viewModel.options.theme == "Adventure")
        #expect(viewModel.options.length == .medium)
        
        viewModel.options = StoryOptions(length: .long, theme: "Magic", characters: ["wizard"])
        
        #expect(viewModel.options.theme == "Magic")
        #expect(viewModel.options.length == .long)
        #expect(viewModel.options.characters == ["wizard"])
    }
}

// MARK: - Test Helper Classes

/// Mock service that fails with specific error types for testing error handling
private class FailingStoryGenerationService: StoryGenerationServiceProtocol {
    enum TestErrorType {
        case invalidProfile
        case invalidOptions
        case generationFailed
        case networkError
        case quotaExceeded
        case serviceUnavailable
        case customError
    }
    
    private let errorType: TestErrorType
    
    init(errorType: TestErrorType) {
        self.errorType = errorType
    }
    
    func generateStory(for profile: UserProfile, with options: StoryOptions) async throws -> Story {
        switch errorType {
        case .invalidProfile:
            throw StoryGenerationError.invalidProfile
        case .invalidOptions:
            throw StoryGenerationError.invalidOptions
        case .generationFailed:
            throw StoryGenerationError.generationFailed
        case .networkError:
            throw StoryGenerationError.networkError
        case .quotaExceeded:
            throw StoryGenerationError.quotaExceeded
        case .serviceUnavailable:
            throw StoryGenerationError.serviceUnavailable
        case .customError:
            throw NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Custom test error"])
        }
    }
    
    func generateDailyStory(for profile: UserProfile) async throws -> Story {
        return try await generateStory(for: profile, with: StoryOptions(length: .medium, theme: "Adventure", characters: []))
    }
    
    func canGenerateStory(for profile: UserProfile, with options: StoryOptions) -> Bool {
        return false
    }
    
    func getSuggestedThemes(for profile: UserProfile) -> [String] {
        return []
    }
    
    func getEstimatedGenerationTime(for options: StoryOptions) -> TimeInterval {
        return 1.0
    }
}
