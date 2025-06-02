import SwiftUI

struct CustomizeStoryView: View {
  @ObservedObject var viewModel: StoryGenerationViewModel
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
