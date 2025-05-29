import SwiftUI

struct CustomizeHeaderView: View {
  var body: some View {
    VStack(spacing: 16) {
      // Icon
      ZStack {
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.purple, Color.blue]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 80, height: 80)
          .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        
        Image(systemName: "paintbrush.fill")
          .font(.system(size: 35))
          .foregroundColor(.white)
      }
      
      VStack(spacing: 8) {
        GradientText(
          "Customize Your Story",
          font: .system(size: 28, weight: .bold, design: .rounded),
          colors: [Color.purple, Color.blue]
        )
        .multilineTextAlignment(.center)
        
        Text("Create the perfect adventure")
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
    CustomizeHeaderView()
      .padding()
  }
}
