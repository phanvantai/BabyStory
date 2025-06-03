import SwiftUI

struct StoryActionButtonsView: View {
  var showListen: Bool
  
  var body: some View {
    VStack(spacing: 16) {
      if showListen {
        Button(action: { /* Play narration (dummy) */ }) {
          HStack(spacing: 12) {
            Image(systemName: "play.circle.fill")
              .font(.title2)
            Text("story_listen_to_story".localized)
              .font(.headline)
              .fontWeight(.semibold)
          }
        }
        .buttonStyle(PrimaryButtonStyle(colors: [Color.blue, Color.purple]))
      }
    }
  }
}

#Preview("Action Buttons - Listen") {
  StoryActionButtonsView(showListen: true)
    .padding()
}

#Preview("Action Buttons - No Buttons") {
  StoryActionButtonsView(showListen: false)
    .padding()
}
