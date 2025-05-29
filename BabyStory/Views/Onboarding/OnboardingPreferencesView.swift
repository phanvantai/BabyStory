import SwiftUI

struct OnboardingPreferencesView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  var onNext: () -> Void
  @State private var isAnimating = false
  @State private var showSuccessAnimation = false
  @State private var showTimePicker = false
  
  var body: some View {
    ZStack {
      // Background
      AppGradientBackground()
      
      // Floating decorative elements
      FloatingStars(count: 12)
      
      ScrollView {
        VStack(spacing: 24) {
          // Header section
          AnimatedEntrance(delay: 0.2) {
            PreferencesHeaderView(
              isAnimating: $isAnimating,
              showSuccessAnimation: $showSuccessAnimation
            )
            .padding(.bottom, 10)
          }
          
          // Story time picker section
          AnimatedEntrance(delay: 0.4) {
            // Story time picker
            StoryTimeDisplay(
              storyTime: $viewModel.storyTime,
              onTap: { showTimePicker = true }
            )
            .padding(.horizontal, 24)
          }
          
          AnimatedEntrance(delay: 0.5) {
            // Story recommendations based on selected time
            StoryRecommendations(recommendations: getStoryRecommendations())
              .padding(.horizontal, 24)
          }
          
          // Profile summary section
          AnimatedEntrance(delay: 0.7) {
            ProfileSummarySection(viewModel: viewModel)
              .padding(.horizontal, 24)
              .padding(.top, 10)
          }
          
          // Finish button
          AnimatedEntrance(delay: 0.9) {
            FinishOnboardingFooter(onFinish: {
              viewModel.saveProfile()
              onNext()
            })
            .padding(.top, 20)
          }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
      }
      .onAppear {
        isAnimating = true
        
        // Delayed success animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          showSuccessAnimation = true
        }
      }
      
      // Time picker popup overlay
      if showTimePicker {
        TimePickerOverlay(
          showTimePicker: $showTimePicker,
          storyTime: $viewModel.storyTime
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showTimePicker)
      }
    }
  }
  
  // Helper function to get time-based story recommendations
  private func getStoryRecommendations() -> [String] {
    let hour = Calendar.current.component(.hour, from: viewModel.storyTime)
    
    switch hour {
      case 6...11:
        return ["Morning Adventures", "Wake-up Stories", "Breakfast Tales", "Sunny Day Fun"]
      case 12...17:
        return ["Afternoon Play", "Learning Stories", "Outdoor Adventures", "Friend Tales"]
      case 18...21:
        return ["Bedtime Stories", "Calm Adventures", "Dream Journeys", "Goodnight Tales"]
      default:
        return ["Peaceful Dreams", "Quiet Stories", "Sleep Adventures", "Gentle Tales"]
    }
  }
}

#Preview {
  OnboardingPreferencesView(
    viewModel: OnboardingViewModel(),
    onNext: {
      print("Onboarding finished!")
    }
  )
}
