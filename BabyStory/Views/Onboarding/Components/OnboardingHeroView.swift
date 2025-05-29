import SwiftUI

struct OnboardingHeroView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Book icon with animation
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .rotationEffect(.degrees(isAnimating ? 5 : -5))
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            // Floating elements around the book
            HStack(spacing: 40) {
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 20, height: 20)
                    .offset(y: isAnimating ? -10 : 10)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(0.5),
                        value: isAnimating
                    )
                
                Spacer()
                
                Circle()
                    .fill(Color.orange.opacity(0.8))
                    .frame(width: 16, height: 16)
                    .offset(y: isAnimating ? 10 : -10)
                    .animation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                        .delay(0.8),
                        value: isAnimating
                    )
            }
            .frame(width: 160)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        OnboardingHeroView(isAnimating: .constant(true))
    }
}
