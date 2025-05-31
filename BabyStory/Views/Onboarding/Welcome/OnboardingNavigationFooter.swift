import SwiftUI

struct OnboardingNavigationFooter: View {
  var pageIndex: Int = 0
  var totalPages: Int = 3
  var buttonText: String = "onboarding_welcome_lets_begin".localized
  var onNext: () -> Void
  
  var body: some View {
    VStack(spacing: 16) {
      Button(action: onNext) {
        HStack(spacing: 12) {
          Text(buttonText)
            .font(.headline)
            .fontWeight(.semibold)
          
          Image(systemName: "arrow.right.circle.fill")
            .font(.title3)
        }
      }
      .buttonStyle(PrimaryButtonStyle())
      
      // Indicator dots
      HStack(spacing: 8) {
        ForEach(0..<totalPages, id: \.self) { index in
          Circle()
            .fill(index == pageIndex ? Color.purple : Color.purple.opacity(0.3))
            .frame(width: index == pageIndex ? 12 : 8, height: index == pageIndex ? 12 : 8)
        }
      }
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 50)
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    OnboardingNavigationFooter(onNext: {
      print("Next button tapped")
    })
  }
}
