import SwiftUI

struct CharactersInputView: View {
  @Binding var charactersText: String
  var onTextChanged: (String) -> Void
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "person.2.fill")
          .foregroundColor(.cyan)
          .font(.title3)
        Text("generate_story_characters_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      VStack(spacing: 12) {
        TextField("generate_story_characters_placeholder".localized, text: $charactersText)
          .textFieldStyle(CustomTextFieldStyle())
          .onChange(of: charactersText) { oldValue, newValue in
            onTextChanged(newValue)
          }
        
        Text("generate_story_characters_help_text".localized)
          .font(.caption)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
    .padding(20)
    .appCardStyle()
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    CharactersInputView(
      charactersText: .constant("brave knight, friendly dragon"),
      onTextChanged: { _ in }
    )
    .padding()
  }
}
