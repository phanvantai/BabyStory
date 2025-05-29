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
          
          // Welcome text
          AnimatedEntrance(delay: 0.6) {
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
          
          // Description
          AnimatedEntrance(delay: 1.0) {
            VStack(spacing: 12) {
              Text("Create magical bedtime stories")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
              
              Text("Personalized adventures that spark imagination and create lasting memories for your little one")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            }
            .padding(.horizontal, 32)
          }
        }
        
        Spacer()
        
        // Next button
        AnimatedEntrance(delay: 1.4) {
          VStack(spacing: 16) {
            Button(action: onNext) {
              HStack(spacing: 12) {
                Text("Let's Begin")
                  .font(.headline)
                  .fontWeight(.semibold)
                
                Image(systemName: "arrow.right.circle.fill")
                  .font(.title3)
              }
            }
            .buttonStyle(PrimaryButtonStyle())
            
            // Indicator dots
            HStack(spacing: 8) {
              Circle()
                .fill(Color.purple)
                .frame(width: 12, height: 12)
              
              Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 8, height: 8)
              
              Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 8, height: 8)
            }
          }
          .padding(.horizontal, 32)
          .padding(.bottom, 50)
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
