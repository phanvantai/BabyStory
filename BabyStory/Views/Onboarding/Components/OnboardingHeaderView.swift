import SwiftUI

struct OnboardingHeaderView: View {
    @Binding var isAnimating: Bool
    let title: String
    let subtitle: String
    let iconName: String
    let gradientColors: [Color] = [Color.purple, Color.pink]
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Image(systemName: iconName)
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            VStack(spacing: 8) {
                GradientText(
                    title,
                    font: .system(size: 28, weight: .bold, design: .rounded),
                    colors: gradientColors
                )
                .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        OnboardingHeaderView(
            isAnimating: .constant(true),
            title: "Tell us about your baby",
            subtitle: "This helps us create the perfect stories",
            iconName: "person.circle.fill"
        )
    }
}
