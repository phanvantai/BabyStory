import SwiftUI

struct StoryDetailView: View, Identifiable {
    let id = UUID()
    let story: Story
    
    var body: some View {
        StoryView(story: story)
    }
}
