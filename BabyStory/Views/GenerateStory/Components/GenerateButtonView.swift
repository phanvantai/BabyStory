import SwiftUI

struct GenerateButtonView: View {
  var onGenerate: () -> Void
  
  var body: some View {
    Button(action: onGenerate) {
      HStack(spacing: 12) {
        Image(systemName: "wand.and.stars")
          .font(.title3)
        Text("Create My Story")
          .font(.headline)
          .fontWeight(.semibold)
      }
    }
    .buttonStyle(PrimaryButtonStyle(colors: [Color.purple, Color.pink]))
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    GenerateButtonView(onGenerate: {})
      .padding()
  }
}
