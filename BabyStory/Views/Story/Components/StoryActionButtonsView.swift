import SwiftUI

struct StoryActionButtonsView: View {
  var showListen: Bool
  var showSave: Bool
  var onSave: (() -> Void)?
  
  var body: some View {
    VStack(spacing: 16) {
      if showListen {
        Button(action: { /* Play narration (dummy) */ }) {
          HStack(spacing: 12) {
            Image(systemName: "play.circle.fill")
              .font(.title2)
            Text("Listen to Story")
              .font(.headline)
              .fontWeight(.semibold)
          }
        }
        .buttonStyle(PrimaryButtonStyle(colors: [Color.blue, Color.purple]))
      }
      
      if showSave, let onSave = onSave {
        Button(action: onSave) {
          HStack(spacing: 12) {
            Image(systemName: "star.fill")
              .font(.title3)
            Text("Save to Library")
              .font(.headline)
              .fontWeight(.medium)
          }
        }
        .buttonStyle(SecondaryButtonStyle())
      }
    }
  }
}

#Preview("Action Buttons - All") {
  StoryActionButtonsView(
    showListen: true,
    showSave: true,
    onSave: { print("Save tapped") }
  )
  .padding()
}

#Preview("Action Buttons - Listen Only") {
  StoryActionButtonsView(
    showListen: true,
    showSave: false
  )
  .padding()
}

#Preview("Action Buttons - Save Only") {
  StoryActionButtonsView(
    showListen: false,
    showSave: true,
    onSave: { print("Save tapped") }
  )
  .padding()
}
