import SwiftUI

struct PreferencesHeaderView: View {
  @Binding var isAnimating: Bool
  @Binding var showSuccessAnimation: Bool
  
  var body: some View {
    VStack(spacing: 20) {
      // Success icon with celebration animation
      ZStack {
        // Outer celebration ring
        Circle()
          .stroke(
            LinearGradient(
              gradient: Gradient(colors: [Color.orange, Color.pink, Color.purple]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 4
          )
          .frame(width: 140, height: 140)
          .scaleEffect(showSuccessAnimation ? 1.2 : 1.0)
          .opacity(showSuccessAnimation ? 0.3 : 0.8)
          .animation(
            .easeOut(duration: 1.5)
            .repeatForever(autoreverses: true),
            value: showSuccessAnimation
          )
        
        // Main icon background
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.green, Color.teal]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 100, height: 100)
          .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        
        // Clock icon
        Image(systemName: "clock.fill")
          .font(.system(size: 45))
          .foregroundColor(.white)
      }
      .rotationEffect(.degrees(isAnimating ? 3 : -3))
      .animation(
        .easeInOut(duration: 2.5)
        .repeatForever(autoreverses: true),
        value: isAnimating
      )
      
      // Title and description
      VStack(spacing: 16) {
        GradientText(
          "onboarding_preferences_perfect_almost_done".localized,
          font: .system(size: 32, weight: .bold, design: .rounded)
        )
        .multilineTextAlignment(.center)
        
        VStack(spacing: 8) {
          Text("onboarding_preferences_when_story_time".localized)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
          
          Text("onboarding_preferences_story_time_description".localized)
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    PreferencesHeaderView(
      isAnimating: .constant(true),
      showSuccessAnimation: .constant(true)
    )
    .padding()
  }
}
