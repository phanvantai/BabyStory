import Foundation

class StoryGenerationViewModel: ObservableObject {
    @Published var options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
    @Published var isLoading = false
    @Published var generatedStory: Story?
    
    func generateStory(profile: UserProfile, options: StoryOptions?) async {
        isLoading = true
        // Simulate async AI generation
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        let story = Story(
            id: UUID(),
            title: "The Amazing Adventure",
            content: "Once upon a time, \(profile.name) went on a magical journey...",
            date: Date(),
            isFavorite: false
        )
        await MainActor.run {
            self.generatedStory = story
            self.isLoading = false
        }
    }
}
