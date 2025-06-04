import SwiftUI

struct HomeView: View {
  @ObservedObject var viewModel: HomeViewModel
  @EnvironmentObject var appViewModel: AppViewModel
  @ObservedObject private var languageManager = LanguageManager.shared
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
                name: "home_little_one".localized,
                subtitle: "home_ready_for_adventure".localized
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
                showFavorites: false // Disabled for now, will be added later
              )
            }
            
            // Quick stats or story time reminder
            if let profile = viewModel.profile {
              AnimatedEntrance(delay: 0.6) {
                if let config = appViewModel.storyGenerationConfig,
                   !config.canGenerateNewStory {
                  StoryUsageLimitView(
                    storiesGenerated: config.storiesGeneratedToday,
                    dailyLimit: config.dailyStoryLimit,
                    tier: config.subscriptionTier
                  )
                  .padding(.horizontal, 4)
                }
              }
              
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
        .id(languageManager.currentLanguage) // Force refresh when language changes
      }
      .navigationDestination(isPresented: $showCustomize) {
        CustomizeStoryView(viewModel: storyGenVM) {
          viewModel.generateCustomStory(using: storyGenVM, appViewModel: appViewModel) { story in
            generatedStory = story
            showStory = true
          }
        }
        .customBackButton(label: "home_home_button".localized)
      }
      .navigationDestination(isPresented: $showLibrary) {
        LibraryView(viewModel: libraryVM)
          .customBackButton(label: "home_home_button".localized)
      }
      .navigationDestination(isPresented: $showProgress) {
        ReadingProgressView(profile: viewModel.profile)
          .customBackButton(label: "home_home_button".localized)
      }
      .navigationDestination(isPresented: $showStory) {
        if let story = generatedStory {
          StoryView(story: story)
            .customBackButton(label: "home_back_button".localized)
        } else {
          Text("home_no_story_generated".localized)
            .customBackButton(label: "home_home_button".localized)
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
      .sheet(isPresented: $storyGenVM.showPaywall, onDismiss: {
        storyGenVM.showPaywall = false
      }) {
        if let config = appViewModel.storyGenerationConfig {
          PaywallView(
            onClose: { storyGenVM.showPaywall = false },
            onUpgrade: {
              // Update the story generation config after successful purchase
              if let updatedConfig = storyGenVM.storyGenerationConfig {
                appViewModel.updateStoryGenerationConfig(updatedConfig)
              }
              storyGenVM.showPaywall = false
            },
            config: config
          )
        }
      }
      .onAppear {
        libraryVM.loadStories()
        // Inject story generation config from app view model
        if let config = appViewModel.storyGenerationConfig {
          storyGenVM.storyGenerationConfig = config
        }
      }
      .onChange(of: appViewModel.storyGenerationConfig) { oldValue, newValue in
        // Update story generation config when it changes in app view model
        if let newConfig = newValue {
          storyGenVM.storyGenerationConfig = newConfig
        }
      }
    }
  }
}

#Preview {
  HomeView(viewModel: HomeViewModel())
}
