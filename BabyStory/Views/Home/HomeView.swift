import SwiftUI

struct HomeView: View {
  @ObservedObject var viewModel: HomeViewModel
  @State private var showCustomize = false
  @State private var showLibrary = false
  @State private var showProgress = false
  @State private var showStory = false
  @State private var showSettings = false
  @State private var generatedStory: Story? = nil
  
  // Lazy initialization of view models to improve performance
  @StateObject private var storyGenVM = StoryGenerationViewModel()
  @StateObject private var libraryVM = LibraryViewModel()
  @StateObject private var settingsVM = SettingsViewModel()
  
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
              TodaysAdventureCard(
                storyGenVM: storyGenVM,
                homeVM: viewModel
              ) { story in
                generatedStory = story
                showStory = true
              }
            }
            
            // Action cards grid
            AnimatedEntrance(delay: 0.5) {
              StoryOptionsGrid(
                onCustomTapped: { showCustomize = true },
                onLibraryTapped: { showLibrary = true },
                onProgressTapped: { showProgress = true },
                onFavoritesTapped: { showLibrary = true },
                showCustomStory: true,
                showLibrary: true,
                showProgress: false, // Disabled for now, will be added later
                showFavorites: true
              )
            }
            
            // Quick stats or story time reminder
            if let profile = viewModel.profile {
              AnimatedEntrance(delay: 0.7) {
                StoryTimeCard(
                  storyTime: profile.storyTime,
                  storiesCount: libraryVM.stories.count
                )
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
        .customBackButton(label: "Home")
      }
      .navigationDestination(isPresented: $showLibrary) {
        LibraryView(viewModel: libraryVM)
          .customBackButton(label: "Home")
      }
      .navigationDestination(isPresented: $showProgress) {
        ReadingProgressView(profile: viewModel.profile)
          .customBackButton(label: "Home")
      }
      .navigationDestination(isPresented: $showStory) {
        if let story = generatedStory {
          StoryView(story: story, onSave: {
            viewModel.saveStory(story)
            libraryVM.loadStories()
          }, showSave: true)
          .customBackButton(label: "Back")
        } else {
          Text("No story generated.")
            .customBackButton(label: "Home")
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
