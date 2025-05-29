import SwiftUI

struct LibraryView: View {
  @ObservedObject var viewModel: LibraryViewModel
  @State private var selectedStory: Story?
  
  var body: some View {
    NavigationStack {
      ZStack {
        AppGradientBackground()
        FloatingStars(count: 12)
        
        ScrollView {
          VStack(spacing: 24) {
            // Header
            AnimatedEntrance(delay: 0.1) {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  GradientText(
                    "Story Library",
                    colors: [.blue, .purple]
                  )
                  .font(.largeTitle)
                  .fontWeight(.bold)
                  
                  Text("\(viewModel.stories.count) magical stories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                Spacer()
                
                Image(systemName: "books.vertical.fill")
                  .font(.title)
                  .foregroundColor(.blue)
              }
              .padding(.horizontal, 24)
              .padding(.top, 20)
            }
            
            // Stories Grid
            if viewModel.stories.isEmpty {
              AnimatedEntrance(delay: 0.3) {
                VStack(spacing: 16) {
                  Image(systemName: "book.closed.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue.opacity(0.5))
                  
                  Text("No Stories Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                  
                  Text("Create your first magical story to see it here!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(40)
                .appCardStyle()
                .padding(.horizontal, 24)
              }
            } else {
              LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(Array(viewModel.stories.enumerated()), id: \.element.id) { index, story in
                  AnimatedEntrance(delay: 0.3 + Double(index) * 0.1) {
                    StoryCard(story: story) {
                      selectedStory = story
                    }
                  }
                }
              }
              .padding(.horizontal, 24)
            }
            
            Spacer(minLength: 100)
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            // TODO: Add filter/sort options
          }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
              .foregroundColor(.purple)
          }
        }
      }
      .sheet(item: $selectedStory) { story in
        StoryDetailView(story: story)
      }
    }
  }
}

// MARK: - Previews
#Preview("Empty Library") {
  LibraryView(viewModel: LibraryViewModel.mockEmpty)
}

#Preview("Populated Library") {
  LibraryView(viewModel: LibraryViewModel.mockPopulated)
}

// MARK: - Mock Data for Previews
extension LibraryViewModel {
  static var mockEmpty: LibraryViewModel {
    let viewModel = LibraryViewModel()
    viewModel.stories = []
    return viewModel
  }
  
  static var mockPopulated: LibraryViewModel {
    let viewModel = LibraryViewModel()
    viewModel.stories = [
      Story(
        id: UUID(),
        title: "The Magical Forest Adventure",
        content: "Once upon a time, in a magical forest filled with talking animals and glowing flowers...",
        date: Date().addingTimeInterval(-86400), // 1 day ago
        isFavorite: true
      ),
      Story(
        id: UUID(),
        title: "Princess Luna and the Star Castle",
        content: "High above the clouds, Princess Luna discovered a castle made entirely of stardust...",
        date: Date().addingTimeInterval(-172800), // 2 days ago
        isFavorite: false
      ),
      Story(
        id: UUID(),
        title: "The Dragon Who Loved to Bake",
        content: "In a cozy cave at the edge of town lived Sparkle, a friendly dragon who loved baking cookies...",
        date: Date().addingTimeInterval(-259200), // 3 days ago
        isFavorite: true
      ),
      Story(
        id: UUID(),
        title: "Captain Whiskers' Ocean Quest",
        content: "Captain Whiskers the cat set sail on a grand adventure across the seven seas...",
        date: Date().addingTimeInterval(-345600), // 4 days ago
        isFavorite: false
      ),
      Story(
        id: UUID(),
        title: "The Robot Who Wanted Friends",
        content: "Beep Boop was a little robot who lived all alone in a big city...",
        date: Date().addingTimeInterval(-432000), // 5 days ago
        isFavorite: false
      ),
      Story(
        id: UUID(),
        title: "The Enchanted Garden Mystery",
        content: "When Emma discovered a hidden door in her grandmother's garden...",
        date: Date().addingTimeInterval(-518400), // 6 days ago
        isFavorite: true
      )
    ]
    return viewModel
  }
}
