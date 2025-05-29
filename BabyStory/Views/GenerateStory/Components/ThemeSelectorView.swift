import SwiftUI

struct ThemeSelectorView: View {
  @Binding var selectedTheme: StoryTheme
  var onThemeSelected: (StoryTheme) -> Void
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "sparkles")
          .foregroundColor(.pink)
          .font(.title3)
        Text("Story Theme")
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
        ForEach(StoryTheme.allCases, id: \.self) { theme in
          Button(action: {
            selectedTheme = theme
            onThemeSelected(theme)
          }) {
            ThemeItemView(theme: theme, isSelected: selectedTheme == theme)
          }
          .buttonStyle(PlainButtonStyle())
        }
      }
      
      if selectedTheme != .adventure {
        Text(selectedTheme.description)
          .font(.caption)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.top, 8)
      }
    }
    //        .padding(20)
    //        .appCardStyle()
  }
}

struct ThemeItemView: View {
  let theme: StoryTheme
  let isSelected: Bool
  
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: theme.icon)
        .font(.title2)
        .foregroundColor(isSelected ? .white : .primary)
      
      Text(theme.rawValue)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(isSelected ? .white : .primary)
        .multilineTextAlignment(.center)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 80)
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(isSelected ?
              LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.pink]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ) :
                LinearGradient(
                  gradient: Gradient(colors: [AppTheme.cardBackground.opacity(0.8), AppTheme.cardBackground.opacity(0.8)]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
             )
        .stroke(isSelected ? Color.purple : AppTheme.defaultCardBorder, lineWidth: isSelected ? 2 : 1)
        .shadow(color: isSelected ? Color.purple.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 8 : 4, x: 0, y: 2)
    )
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    ThemeSelectorView(
      selectedTheme: .constant(.adventure),
      onThemeSelected: { _ in }
    )
    .padding()
  }
}
