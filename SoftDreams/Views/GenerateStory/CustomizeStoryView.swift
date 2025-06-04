import SwiftUI

struct CustomizeStoryView: View {
  @ObservedObject var viewModel: StoryGenerationViewModel
  var onGenerate: () -> Void
  @State private var charactersText: String = ""
  @State private var selectedTheme: StoryTheme = .adventure
  @State private var showContent = false
  @State private var showUpgradeSheet = false
  
  var body: some View {
    ZStack {
      // Background
      AppGradientBackground()
      
      // Floating decorative elements
      FloatingStars(count: 8)
      
      ScrollView {
        VStack(spacing: 32) {
          // Header
          AnimatedEntrance(delay: 0.2) {
            CustomizeHeaderView()
          }
          
          // Story Usage Limit Section
          if let config = viewModel.storyGenerationConfig {
            AnimatedEntrance(delay: 0.3) {
              StoryUsageLimitView(
                storiesGenerated: config.storiesGeneratedToday,
                dailyLimit: config.dailyStoryLimit,
                tier: config.subscriptionTier
              )
              .padding(.horizontal, 4)
            }
          }
          
          // Story Length Section
          AnimatedEntrance(delay: 0.4) {
            StoryLengthSelector(selectedLength: $viewModel.options.length)
          }
          
          // Theme Selection Section
          AnimatedEntrance(delay: 0.6) {
            ThemeSelectorView(
              selectedTheme: $selectedTheme,
              onThemeSelected: { theme in
                viewModel.options.theme = theme.rawValue
              }
            )
          }
          
          // AI Model Selector (only if config is available)
          if let config = viewModel.storyGenerationConfig {
            AnimatedEntrance(delay: 0.7) {
              AIModelSelectorView(
                selectedModel: Binding(
                  get: { config.selectedModel },
                  set: { newModel in
                    if var updatedConfig = viewModel.storyGenerationConfig {
                      let _ = updatedConfig.selectModel(newModel)
                      viewModel.storyGenerationConfig = updatedConfig
                      
                      // Save the updated config
                      if let appVM = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appViewModel {
                        appVM.updateStoryGenerationConfig(updatedConfig)
                      }
                    }
                  }
                ),
                subscriptionTier: config.subscriptionTier
              )
            }
          }
          
          // Characters Section
          AnimatedEntrance(delay: 0.8) {
            CharactersInputView(
              charactersText: $charactersText,
              onTextChanged: { newValue in
                viewModel.options.characters = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
              }
            )
          }
          
          // Generate Button
          AnimatedEntrance(delay: 1.0) {
            GenerateButtonView(
              onGenerate: {
                if !charactersText.isEmpty {
                  viewModel.options.characters = charactersText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                }
                onGenerate()
              },
              isGenerating: viewModel.isGenerating
            )
          }
          
          Spacer(minLength: 50)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      showContent = true
      // Initialize selected theme from viewModel
      if let currentTheme = StoryTheme.allCases.first(where: { $0.rawValue == viewModel.options.theme }) {
        selectedTheme = currentTheme
      }
      // Initialize characters text from viewModel
      charactersText = viewModel.options.characters.joined(separator: ", ")
    }
    // Listen for paywall trigger
    .onChange(of: viewModel.showPaywall) { oldValue, newValue in
      if newValue {
        showUpgradeSheet = true
        viewModel.showPaywall = false // Reset flag after handling
      }
    }
    // Show paywall sheet when needed
    .sheet(isPresented: $showUpgradeSheet) {
      if let config = viewModel.storyGenerationConfig {
        PaywallView(
          onClose: { showUpgradeSheet = false },
          onUpgrade: {
            handleUpgradeSubscription()
            showUpgradeSheet = false
          },
          config: config
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
      }
    }
  }
  
  // Handle subscription upgrade
  private func handleUpgradeSubscription() {
    // For demo purposes, we'll simply upgrade the user's subscription to premium
    // In a real app, this would show the App Store's subscription UI
    if var config = viewModel.storyGenerationConfig {
      config.upgradeSubscription(to: .premium)
      
      // Update the config through AppViewModel to ensure it's properly saved
      if let appVM = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appViewModel {
        appVM.updateStoryGenerationConfig(config)
        
        // Also update our local copy
        viewModel.storyGenerationConfig = config
      }
    }
  }
}

// MARK: - Preview
#Preview {
  NavigationStack {
    CustomizeStoryView(
      viewModel: {
        let vm = StoryGenerationViewModel()
        // Initialize with some sample data
        vm.options.theme = "Adventure"
        vm.options.length = .medium
        vm.options.characters = ["brave knight", "friendly dragon"]
        return vm
      }()
    ) {
      print("Generate story tapped in preview")
    }
    .navigationTitle("generate_story_customize_nav_title".localized)
  }
}
