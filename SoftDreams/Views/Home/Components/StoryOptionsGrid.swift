import SwiftUI

struct StoryOptionsGrid: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    let onCustomTapped: () -> Void
    let onLibraryTapped: () -> Void
    let onProgressTapped: () -> Void
    let onFavoritesTapped: () -> Void
    
    // Feature flags
    var showCustomStory: Bool = true
    var showLibrary: Bool = true
    var showProgress: Bool = false // Disabled by default, will add later
    var showFavorites: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "rectangle.grid.2x2.fill")
                    .foregroundColor(.purple)
                    .font(.title3)
                Text("home_story_options".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                if showCustomStory {
                    ActionCard(
                        title: "home_custom_story".localized,
                        subtitle: "home_custom_story_subtitle".localized,
                        icon: "paintbrush.fill",
                        gradientColors: [Color.purple, Color.blue]
                    ) {
                        onCustomTapped()
                    }
                }
                
                if showLibrary {
                    ActionCard(
                        title: "home_story_library".localized,
                        subtitle: "home_story_library_subtitle".localized,
                        icon: "books.vertical.fill",
                        gradientColors: [Color.blue, Color.cyan]
                    ) {
                        onLibraryTapped()
                    }
                }
                
                if showProgress {
                    ActionCard(
                        title: "home_progress".localized,
                        subtitle: "home_progress_subtitle".localized,
                        icon: "chart.line.uptrend.xyaxis",
                        gradientColors: [Color.green, Color.mint]
                    ) {
                        onProgressTapped()
                    }
                    .overlay(alignment: .topTrailing) {
                        Text("home_coming_soon".localized)
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
                        title: "home_favorites".localized,
                        subtitle: "home_favorites_subtitle".localized,
                        icon: "heart.fill",
                        gradientColors: [Color.pink, Color.red]
                    ) {
                        onFavoritesTapped()
                    }
                }
            }
        }
        .id(languageManager.currentLanguage) // Force refresh when language changes
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
