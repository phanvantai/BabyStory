import SwiftUI

struct GenerateButtonView: View {
  var onGenerate: () -> Void
  var isGenerating: Bool = false
  
  var body: some View {
    Button(action: onGenerate) {
      HStack(spacing: 12) {
        if isGenerating {
          ProgressView()
            .scaleEffect(0.8)
            .foregroundColor(.white)
        } else {
          Image(systemName: "wand.and.stars")
            .font(.title3)
        }
        Text(isGenerating ? "generate_story_generating_button".localized : "generate_story_create_button".localized)
          .font(.headline)
          .fontWeight(.semibold)
      }
    }
    .disabled(isGenerating)
    .buttonStyle(PrimaryButtonStyle(colors: [Color.purple, Color.pink]))
  }
}

#Preview {
  VStack(spacing: 20) {
    ZStack {
      Color.gray.opacity(0.2).ignoresSafeArea()
      VStack(spacing: 16) {
        Text("Normal State")
          .font(.headline)
        GenerateButtonView(onGenerate: {})
          .padding()
        
        Text("Loading State")
          .font(.headline)
        GenerateButtonView(onGenerate: {}, isGenerating: true)
          .padding()
      }
    }
  }
}
