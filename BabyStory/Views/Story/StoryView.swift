import SwiftUI

struct StoryView: View {
    let story: Story
    var onSave: (() -> Void)? = nil
    var showSave: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    )
                Text(story.title)
                    .font(.title)
                    .bold()
                Text(story.content)
                    .font(.body)
                HStack(spacing: 32) {
                    Button(action: { /* Play narration (dummy) */ }) {
                        Label("Play", systemImage: "play.circle")
                    }
                    if showSave, let onSave = onSave {
                        Button(action: onSave) {
                            Label("Save to Library", systemImage: "star")
                        }
                    }
                }
            }
            .padding()
        }
    }
}
