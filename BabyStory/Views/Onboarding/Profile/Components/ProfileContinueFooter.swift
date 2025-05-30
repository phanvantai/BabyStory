import SwiftUI

struct ProfileContinueFooter: View {
  @ObservedObject var viewModel: OnboardingViewModel
  var onNext: () -> Void
  var currentPageIndex: Int = 1
  var totalPages: Int = 3
  
  var body: some View {
    VStack(spacing: 16) {
      Button(action: onNext) {
        HStack(spacing: 12) {
          Text("Continue")
            .font(.headline)
            .fontWeight(.semibold)
          
          Image(systemName: "arrow.right.circle.fill")
            .font(.title3)
        }
      }
      .buttonStyle(PrimaryButtonStyle(
        colors: viewModel.canProceed ? [Color.purple, Color.pink] : [Color.gray, Color.gray.opacity(0.8)],
        isEnabled: viewModel.canProceed
      ))
      .disabled(!viewModel.canProceed)
      
      // Progress dots
      HStack(spacing: 8) {
        ForEach(0..<totalPages, id: \.self) { index in
          Circle()
            .fill(index == currentPageIndex ? Color.purple : Color.purple.opacity(0.3))
            .frame(width: index == currentPageIndex ? 12 : 8, height: index == currentPageIndex ? 12 : 8)
        }
      }
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 32)
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    ProfileContinueFooter(
      viewModel: OnboardingViewModel(),
      onNext: { print("Continue tapped") }
    )
  }
}
