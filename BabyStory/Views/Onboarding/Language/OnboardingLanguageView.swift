import SwiftUI

struct OnboardingLanguageView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  var onNext: () -> Void
  @State private var isAnimating = false
  @State private var showContent = false
  
  var body: some View {
    ZStack {
      // Background
      AppGradientBackground()
      
      // Floating decorative elements
      FloatingStars(count: 15)
      
      ScrollView {
        VStack(spacing: 32) {
          // Header section
          AnimatedEntrance(delay: 0.2) {
            OnboardingHeaderView(
              isAnimating: $isAnimating,
              title: "",
              subtitle: "language_selection_subtitle".localized,
              iconName: "globe"
            )
          }
          
          // Language selection content
          AnimatedEntrance(delay: 0.4) {
            VStack(spacing: 24) {
              LanguageSelector(viewModel: viewModel)
              
              // Language description card
              VStack(spacing: 12) {
                HStack {
                  Image(systemName: "info.circle.fill")
                    .foregroundColor(.cyan)
                    .font(.title3)
                  Text("language_settings".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                  Spacer()
                }
                
                VStack(spacing: 8) {
                  HStack {
                    Text("current_selection".localized)
                      .font(.body)
                      .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.selectedLanguage.fullDisplayName)
                      .font(.body)
                      .fontWeight(.medium)
                      .foregroundColor(.primary)
                  }
                  
                  Text("language_change_later_note".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                }
              }
              .padding(20)
              .appCardStyle()
            }
          }
        }
        .padding(.horizontal, 24)
        
        // Continue button
        AnimatedEntrance(delay: 1.2) {
          LanguageContinueFooter(
            selectedLanguage: viewModel.selectedLanguage,
            onNext: {
              // Save the selected language
              viewModel.selectedLanguage.save()
              onNext()
            },
            currentPageIndex: 0,
            totalPages: 4 // Updated to reflect new total with language step
          )
        }
        .padding(.top, 60)
      }
    }
    .onAppear {
      isAnimating = true
      showContent = true
    }
  }
}

struct LanguageContinueFooter: View {
  let selectedLanguage: Language
  var onNext: () -> Void
  let currentPageIndex: Int
  let totalPages: Int
  
  var body: some View {
    VStack(spacing: 16) {
      Button(action: onNext) {
        HStack(spacing: 12) {
          Text(String(format: "continue_with_language".localized, selectedLanguage.nativeName))
            .font(.headline)
            .fontWeight(.semibold)
          
          Image(systemName: "arrow.right.circle.fill")
            .font(.title3)
        }
      }
      .buttonStyle(PrimaryButtonStyle(colors: [Color.blue, Color.purple]))
      
      // Progress dots
      HStack(spacing: 8) {
        ForEach(0..<totalPages, id: \.self) { index in
          Circle()
            .fill(index == currentPageIndex ? Color.blue : Color.blue.opacity(0.3))
            .frame(width: index == currentPageIndex ? 12 : 8, height: index == currentPageIndex ? 12 : 8)
        }
      }
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 50)
  }
}

#Preview {
  OnboardingLanguageView(
    viewModel: OnboardingViewModel(),
    onNext: {
      print("Language selection completed")
    }
  )
}
