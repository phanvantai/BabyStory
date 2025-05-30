import SwiftUI

struct OnboardingWelcomeTextView: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("Welcome to")
        .font(.title2)
        .fontWeight(.medium)
        .foregroundColor(.primary)
      
      GradientText(
        "Baby Story",
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
