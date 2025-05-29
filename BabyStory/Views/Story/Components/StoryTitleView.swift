import SwiftUI

struct StoryTitleView: View {
  let title: String
  
  var body: some View {
    GradientText(
      title,
      font: .system(size: 32, weight: .bold, design: .rounded)
    )
    .multilineTextAlignment(.center)
  }
}

#Preview("Story Title") {
  StoryTitleView(title: "The Magical Forest Adventure")
    .padding()
}
