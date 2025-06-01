import SwiftUI

struct OnboardingWelcomeTextView: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("onboarding_welcome_welcome_to".localized)
        .font(.title2)
        .fontWeight(.medium)
        .foregroundColor(.primary)
      
      GradientText(
        "onboarding_welcome_app_name".localized,
        font: .system(size: 42, weight: .bold, design: .rounded)
      )
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    OnboardingWelcomeTextView()
  }
}
