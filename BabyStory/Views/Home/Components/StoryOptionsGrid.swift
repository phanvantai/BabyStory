import SwiftUI

struct StoryOptionsGrid: View {
    let onCustomTapped: () -> Void
    let onLibraryTapped: () -> Void
    let onProgressTapped: () -> Void
    let onFavoritesTapped: () -> Void
    
    // Feature flags
    var showCustomStory: Bool = true
    var showLibrary: Bool = true
    var showProgress: Bool = false // Disabled by default, will add later
    var showFavorites: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "rectangle.grid.2x2.fill")
                    .foregroundColor(.purple)
                    .font(.title3)
                Text("Story Options")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                if showCustomStory {
                    ActionCard(
                        title: "Custom Story",
                        subtitle: "Choose themes, characters & more",
                        icon: "paintbrush.fill",
                        gradientColors: [Color.purple, Color.blue]
                    ) {
                        onCustomTapped()
                    }
                }
                
                if showLibrary {
                    ActionCard(
                        title: "Story Library",
                        subtitle: "Browse saved stories",
                        icon: "books.vertical.fill",
                        gradientColors: [Color.blue, Color.cyan]
                    ) {
                        onLibraryTapped()
                    }
                }
                
                if showProgress {
                    ActionCard(
                        title: "Progress",
                        subtitle: "Track reading journey",
                        icon: "chart.line.uptrend.xyaxis",
                        gradientColors: [Color.green, Color.mint]
                    ) {
                        onProgressTapped()
                    }
                    .overlay(alignment: .topTrailing) {
                        Text("Coming Soon")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.orange.gradient)
                            )
                            .padding(8)
                    }
                }
                
                if showFavorites {
                    ActionCard(
                        title: "Favorites",
                        subtitle: "Most loved stories",
                        icon: "heart.fill",
                        gradientColors: [Color.pink, Color.red]
                    ) {
                        onFavoritesTapped()
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        // Default configuration (Progress disabled)
        StoryOptionsGrid(
            onCustomTapped: {},
            onLibraryTapped: {},
            onProgressTapped: {},
            onFavoritesTapped: {}
        )
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        
        // All features enabled
        StoryOptionsGrid(
            onCustomTapped: {},
            onLibraryTapped: {},
            onProgressTapped: {},
            onFavoritesTapped: {},
            showCustomStory: true,
            showLibrary: true, 
            showProgress: true,
            showFavorites: true
        )
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    .padding()
}
