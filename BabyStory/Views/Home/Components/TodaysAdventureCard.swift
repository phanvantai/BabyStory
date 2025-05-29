import SwiftUI

struct TodaysAdventureCard: View {
    @ObservedObject var storyGenVM: StoryGenerationViewModel
    @ObservedObject var homeVM: HomeViewModel
    let onStoryGenerated: (Story) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Today's Adventure")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Button(action: {
                homeVM.generateTodaysStory(using: storyGenVM) { story in
                    if let story = story {
                        onStoryGenerated(story)
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Text("Create Today's Story")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "sparkles")
                        .font(.title3)
                }
            }
            .buttonStyle(PrimaryButtonStyle(colors: [Color.orange, Color.pink]))
            .disabled(storyGenVM.isGenerating)
            
            if storyGenVM.isGenerating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Creating your magical story...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .appCardStyle(
            backgroundColor: Color.orange.opacity(0.1),
            borderColor: Color.orange.opacity(0.3),
            shadowColor: Color.orange.opacity(0.2)
        )
    }
}

#Preview {
    TodaysAdventureCard(
        storyGenVM: StoryGenerationViewModel(),
        homeVM: HomeViewModel(),
        onStoryGenerated: { _ in }
    )
}
