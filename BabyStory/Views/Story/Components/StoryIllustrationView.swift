import SwiftUI

struct StoryIllustrationView: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(
          LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(height: 200)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
      
      VStack(spacing: 12) {
        Image(systemName: "book.pages.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 80, height: 80)
          .foregroundColor(.white)
        
        Text("Story Illustration")
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.8))
      }
    }
  }
}

#Preview("Story Illustration") {
  StoryIllustrationView()
    .padding()
}
