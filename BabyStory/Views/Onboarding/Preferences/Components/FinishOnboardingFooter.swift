import SwiftUI

struct FinishOnboardingFooter: View {
  var onFinish: () -> Void
  
  var body: some View {
    VStack(spacing: 16) {
      Button(action: onFinish) {
        HStack(spacing: 12) {
          Text("Start Creating Stories!")
            .font(.headline)
            .fontWeight(.semibold)
          
          Image(systemName: "sparkles")
            .font(.title3)
        }
      }
      .buttonStyle(PrimaryButtonStyle(colors: [Color.green, Color.teal]))
      
      // Final progress dots
      HStack(spacing: 8) {
        Circle()
          .fill(Color.green.opacity(0.3))
          .frame(width: 8, height: 8)
        
        Circle()
          .fill(Color.green.opacity(0.3))
          .frame(width: 8, height: 8)
        
        Circle()
          .fill(Color.green)
          .frame(width: 12, height: 12)
      }
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 32)
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    FinishOnboardingFooter(onFinish: {})
      .padding()
  }
}
