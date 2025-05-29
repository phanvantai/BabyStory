import Foundation

class LibraryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    
    init() {
        loadStories()
    }
    
    func loadStories() {
        stories = UserDefaultsManager.shared.loadStories()
    }
    
    func toggleFavorite(for story: Story) {
        if let index = stories.firstIndex(where: { $0.id == story.id }) {
            stories[index].isFavorite.toggle()
            UserDefaultsManager.shared.saveStories(stories)
        }
    }
}
