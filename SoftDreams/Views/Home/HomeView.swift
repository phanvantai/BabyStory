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
  @State private var showPremiumFeatures = false
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
              
              // Feedback Card
              AnimatedEntrance(delay: 0.8) {
                FeedbackCard()
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
        CustomizeStoryView(
          viewModel: storyGenVM,
          appViewModel: appViewModel
        ) {
          if let profile = viewModel.profile {
            Task {
              if let story = await storyGenVM.generateCustomStory(profile: profile, appViewModel: appViewModel) {
                generatedStory = story
                showStory = true
              }
            }
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
          HStack(spacing: 16) {
            Button(action: { showPremiumFeatures = true }) {
              Image(systemName: "crown.fill")
                .font(.title3)
                .foregroundColor(.purple)
            }
            
            Button(action: { showSettings = true }) {
              Image(systemName: "gear")
                .font(.title3)
                .foregroundColor(.purple)
            }
          }
        }
      }
      .sheet(isPresented: $showSettings) {
        SettingsView(viewModel: settingsVM)
      }
      .sheet(isPresented: $showPremiumFeatures) {
        if let config = appViewModel.storyGenerationConfig {
          PaywallView(
            onClose: { showPremiumFeatures = false },
            onUpgrade: {
              // The AppViewModel will automatically detect subscription changes
              // through its StoreKit observation, so we don't need to manually update
              showPremiumFeatures = false
            },
            config: config,
            storeKitService: appViewModel.storeKitService
          )
        }
      }
      .onAppear {
        libraryVM.loadStories()
      }
    }
  }
}

#Preview {
  HomeView(viewModel: HomeViewModel())
    .environmentObject(AppViewModel())
    
}
