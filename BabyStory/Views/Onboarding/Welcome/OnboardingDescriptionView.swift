import SwiftUI

struct OnboardingDescriptionView: View {
  var body: some View {
    VStack(spacing: 12) {
      Text("onboarding_welcome_headline".localized)
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
        .multilineTextAlignment(.center)
      
      Text("onboarding_welcome_description".localized)
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .lineLimit(3)
    }
    .padding(.horizontal, 32)
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    OnboardingDescriptionView()
  }
}
