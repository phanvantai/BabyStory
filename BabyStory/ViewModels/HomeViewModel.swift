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
}
