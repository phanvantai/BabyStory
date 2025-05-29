import SwiftUI

struct OnboardingWelcomeView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  var onNext: () -> Void
  @State private var isAnimating = false
  
  var body: some View {
    ZStack {
      // Background
      AppGradientBackground()
      
      // Floating decorative elements
      FloatingStars(count: 20)
      
      VStack(spacing: 0) {
        Spacer()
        
        // Main content
        VStack(spacing: 32) {
          // Hero illustration area
          AnimatedEntrance(delay: 0.3) {
            OnboardingHeroView(isAnimating: $isAnimating)
          }
          
          // Welcome text
          AnimatedEntrance(delay: 0.6) {
            OnboardingWelcomeTextView()
          }
          
          // Description
          AnimatedEntrance(delay: 1.0) {
            OnboardingDescriptionView()
          }
        }
        
        Spacer()
        
        // Navigation controls
        AnimatedEntrance(delay: 1.4) {
          OnboardingNavigationFooter(
            pageIndex: 0,
            totalPages: 3,
            buttonText: "Let's Begin",
            onNext: onNext
          )
        }
      }
    }
    .onAppear {
      isAnimating = true
    }
  }
}

#Preview {
  OnboardingWelcomeView(
    viewModel: OnboardingViewModel(),
    onNext: {
      print("Next button tapped")
    }
  )
}
