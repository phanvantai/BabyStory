import SwiftUI

struct HomeView: View {
  @ObservedObject var viewModel: HomeViewModel
  @StateObject private var storyGenVM = StoryGenerationViewModel()
  @StateObject private var libraryVM = LibraryViewModel()
  @StateObject private var settingsVM = SettingsViewModel()
  @State private var showCustomize = false
  @State private var showLibrary = false
  @State private var showProgress = false
  @State private var showStory = false
  @State private var showSettings = false
  @State private var generatedStory: Story? = nil
  
  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        AppGradientBackground()
        
        // Floating decorative elements
        FloatingStars(count: 15)
        
        ScrollView {
          VStack(spacing: 32) {
            // Welcome header
            if let profile = viewModel.profile {
              WelcomeHeader(
                name: profile.displayName,
                subtitle: profile.getWelcomeSubtitle()
              )
            } else {
              WelcomeHeader(
                name: "Little One",
                subtitle: "Ready for a magical story adventure?"
              )
            }
            
            // Today's story highlight
            AnimatedEntrance(delay: 0.3) {
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
                  viewModel.generateTodaysStory(using: storyGenVM) { story in
                    generatedStory = story
                    showStory = true
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
            
            // Action cards grid
            AnimatedEntrance(delay: 0.5) {
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
                  ActionCard(
                    title: "Custom Story",
                    subtitle: "Choose themes, characters & more",
                    icon: "paintbrush.fill",
                    gradientColors: [Color.purple, Color.blue]
                  ) {
                    showCustomize = true
                  }
                  
                  ActionCard(
                    title: "Story Library",
                    subtitle: "Browse saved stories",
                    icon: "books.vertical.fill",
                    gradientColors: [Color.blue, Color.cyan]
                  ) {
                    showLibrary = true
                  }
                  
                  ActionCard(
                    title: "Progress",
                    subtitle: "Track reading journey",
                    icon: "chart.line.uptrend.xyaxis",
                    gradientColors: [Color.green, Color.mint]
                  ) {
                    showProgress = true
                  }
                  
                  ActionCard(
                    title: "Favorites",
                    subtitle: "Most loved stories",
                    icon: "heart.fill",
                    gradientColors: [Color.pink, Color.red]
                  ) {
                    // Navigate to favorites in library
                    showLibrary = true
                  }
                }
              }
            }
            
            // Quick stats or story time reminder
            if let profile = viewModel.profile {
              AnimatedEntrance(delay: 0.7) {
                VStack(spacing: 16) {
                  HStack {
                    Image(systemName: "clock.fill")
                      .foregroundColor(.purple)
                      .font(.title3)
                    Text("Story Time")
                      .font(.title3)
                      .fontWeight(.semibold)
                    Spacer()
                  }
                  
                  HStack {
                    VStack(alignment: .leading, spacing: 4) {
                      Text("Next story time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                      Text(profile.storyTime, style: .time)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                      Text("Stories read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                      Text("\(libraryVM.stories.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    }
                  }
                }
                .padding(20)
                .appCardStyle()
              }
            }
            
            Spacer(minLength: 100)
          }
          .padding(.horizontal, 24)
          .padding(.top, 20)
        }
      }
      .navigationDestination(isPresented: $showCustomize) {
        CustomizeStoryView(viewModel: storyGenVM) {
          viewModel.generateCustomStory(using: storyGenVM) { story in
            generatedStory = story
            showStory = true
          }
        }
      }
      .navigationDestination(isPresented: $showLibrary) {
        LibraryView(viewModel: libraryVM)
      }
      .navigationDestination(isPresented: $showProgress) {
        ReadingProgressView(profile: viewModel.profile)
      }
      .navigationDestination(isPresented: $showStory) {
        if let story = generatedStory {
          StoryView(story: story, onSave: {
            viewModel.saveStory(story)
            libraryVM.loadStories()
          }, showSave: true)
        } else {
          Text("No story generated.")
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { showSettings = true }) {
            Image(systemName: "gear")
              .font(.title3)
              .foregroundColor(.purple)
          }
        }
      }
      .sheet(isPresented: $showSettings) {
        SettingsView(viewModel: settingsVM)
      }
      .onAppear {
        libraryVM.loadStories()
      }
    }
  }
}

#Preview {
  HomeView(viewModel: HomeViewModel())
}
