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
            StoryRecommendations(recommendations: viewModel.getStoryRecommendations())
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
    .notificationPermissionPrompt(
      context: viewModel.notificationPermissionContext,
      onGranted: viewModel.handleNotificationPermissionGranted,
      onDenied: viewModel.handleNotificationPermissionDenied
    )
    .sheet(isPresented: $viewModel.showNotificationPermissionPrompt) {
      NotificationPermissionSheet(
        permissionManager: NotificationPermissionManager.shared,
        context: viewModel.notificationPermissionContext,
        onPermissionGranted: viewModel.handleNotificationPermissionGranted,
        onPermissionDenied: viewModel.handleNotificationPermissionDenied
      )
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
