import SwiftUI

struct StoryContentView: View {
  let content: String
  
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    AppCard(
      backgroundColor: AppTheme.cardBackground(for: colorScheme).opacity(0.3),
      borderColor: Color(UIColor.separator).opacity(colorScheme == .dark ? 0.4 : 0.2),
      shadowColor: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1)
    ) {
      VStack(alignment: .leading, spacing: 20) {
        Text(content)
          .font(.title3)
          .lineSpacing(6)
          .foregroundColor(AppTheme.primaryText)
      }
      .padding(24)
    }
  }
}

#Preview("Story Content") {
  StoryContentView(content: "Once upon a time, in a magical forest filled with talking animals and glowing flowers, there lived a brave little rabbit named Luna. Luna had soft, silver fur that shimmered like moonlight and eyes as bright as stars.")
    .padding()
}
