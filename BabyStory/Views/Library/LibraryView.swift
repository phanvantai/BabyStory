import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @State private var selectedStory: Story?
    
    var body: some View {
        NavigationStack {
            List(viewModel.stories) { story in
                Button(action: { selectedStory = story }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(story.title)
                                .font(.headline)
                            Text(story.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if story.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .sheet(item: $selectedStory) { story in
                StoryDetailView(story: story)
            }
        }
    }
}
