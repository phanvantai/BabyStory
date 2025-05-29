import Foundation

class HomeViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var stories: [Story] = []
    
    init() {
        refresh()
    }
    
    func refresh() {
        profile = UserDefaultsManager.shared.loadProfile()
        stories = UserDefaultsManager.shared.loadStories()
    }
    
    func saveStory(_ story: Story) {
        stories.append(story)
        UserDefaultsManager.shared.saveStories(stories)
    }
    
    // MARK: - Story Generation Methods
    @MainActor
    func generateTodaysStory(
        using storyGenVM: StoryGenerationViewModel,
        completion: @escaping (Story?) -> Void
    ) {
        Task {
            if let profile = self.profile {
                await storyGenVM.generateStory(profile: profile, options: nil)
                completion(storyGenVM.generatedStory)
            } else {
                completion(nil)
            }
        }
    }
    
    @MainActor
    func generateCustomStory(
        using storyGenVM: StoryGenerationViewModel,
        completion: @escaping (Story?) -> Void
    ) {
        Task {
            if let profile = self.profile {
                await storyGenVM.generateStory(profile: profile, options: storyGenVM.options)
                completion(storyGenVM.generatedStory)
            } else {
                completion(nil)
            }
        }
    }
}
