import SwiftUI

struct CustomizeStoryView: View {
  @ObservedObject var viewModel: StoryGenerationViewModel
  @ObservedObject var appViewModel: AppViewModel
  var onGenerate: () -> Void
  @State private var charactersText: String = ""
  @State private var selectedTheme: StoryTheme = .adventure
  @State private var showContent = false
  
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
          if let config = appViewModel.storyGenerationConfig {
            AnimatedEntrance(delay: 0.3) {
              VStack(spacing: 16) {
                StoryUsageLimitView(
                  storiesGenerated: config.storiesGeneratedToday,
                  dailyLimit: config.dailyStoryLimit,
                  tier: config.subscriptionTier
                )
                .padding(.horizontal, 4)
              }
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
          if let config = appViewModel.storyGenerationConfig {
            AnimatedEntrance(delay: 0.7) {
              AIModelSelectorView(
                selectedModel: Binding(
                  get: { config.selectedModel },
                  set: { newModel in
                    if var updatedConfig = appViewModel.storyGenerationConfig {
                      let _ = updatedConfig.selectModel(newModel)
                      appViewModel.updateStoryGenerationConfig(updatedConfig)
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
                
                // Check if user is free tier and at limit
                if let config = appViewModel.storyGenerationConfig,
                   !config.canGenerateNewStory,
                   config.subscriptionTier == .free {
                  viewModel.showPaywall = true
                } else {
                  onGenerate()
                }
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
    .sheet(isPresented: $viewModel.showPaywall, onDismiss: {
      viewModel.showPaywall = false
    }) {
      if let config = appViewModel.storyGenerationConfig {
        PaywallView(
          onClose: { viewModel.showPaywall = false },
          onUpgrade: {
            // The AppViewModel will automatically detect subscription changes
            viewModel.showPaywall = false
          },
          config: config,
          storeKitService: appViewModel.storeKitService
        )
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
      }(),
      appViewModel: AppViewModel()
    ) {
      print("Generate story tapped in preview")
    }
    .navigationTitle("generate_story_customize_nav_title".localized)
  }
}
