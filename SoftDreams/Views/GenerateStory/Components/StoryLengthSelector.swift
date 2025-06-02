import SwiftUI

struct StoryLengthSelector: View {
  @Binding var selectedLength: StoryLength
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "clock.fill")
          .foregroundColor(.orange)
          .font(.title3)
        Text("generate_story_length_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      VStack(spacing: 12) {
        ForEach(StoryLength.allCases) { length in
          Button(action: {
            selectedLength = length
          }) {
            HStack(spacing: 16) {
              // Icon based on length
              ZStack {
                Circle()
                  .fill(selectedLength == length ?
                        LinearGradient(
                          gradient: Gradient(colors: [Color.orange, Color.red]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                        ) :
                          LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                  )
                  .frame(width: 40, height: 40)
                
                Image(systemName: lengthIcon(for: length))
                  .font(.system(size: 18, weight: .semibold))
                  .foregroundColor(selectedLength == length ? .white : .gray)
              }
              
              // Content
              VStack(alignment: .leading, spacing: 4) {
                Text(lengthTitle(for: length))
                  .font(.headline)
                  .fontWeight(.semibold)
                  .foregroundColor(selectedLength == length ? .primary : .primary)
                
                Text(length.description)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              // Selection indicator
              if selectedLength == length {
                Image(systemName: "checkmark.circle.fill")
                  .font(.title3)
                  .foregroundColor(.orange)
              } else {
                Image(systemName: "circle")
                  .font(.title3)
                  .foregroundColor(.gray.opacity(0.4))
              }
            }
            .padding(16)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(
                  selectedLength == length ?
                  Color.orange.opacity(0.1) :
                    AppTheme.cardBackground.opacity(0.3)
                )
                .stroke(
                  selectedLength == length ?
                  Color.orange.opacity(0.5) :
                    AppTheme.defaultCardBorder,
                  lineWidth: selectedLength == length ? 2 : 1
                )
            )
            .shadow(
              color: selectedLength == length ?
              Color.orange.opacity(0.2) :
                Color.black.opacity(0.05),
              radius: selectedLength == length ? 6 : 3,
              x: 0,
              y: 2
            )
          }
          .buttonStyle(PlainButtonStyle())
          .scaleEffect(selectedLength == length ? 1.02 : 1.0)
          .animation(.easeInOut(duration: 0.2), value: selectedLength)
        }
      }
    }
    .padding(20)
    .appCardStyle()
  }
  
  private func lengthIcon(for length: StoryLength) -> String {
    switch length {
    case .short:
      return "clock.fill"
    case .medium:
      return "clock.badge.fill"
    case .long:
      return "clock.arrow.circlepath"
    }
  }
  
  private func lengthTitle(for length: StoryLength) -> String {
    switch length {
    case .short:
      return "generate_story_length_quick_tale".localized
    case .medium:
      return "generate_story_length_perfect_story".localized
    case .long:
      return "generate_story_length_extended_adventure".localized
    }
  }
}

// MARK: - Preview
#Preview {
  VStack {
    StoryLengthSelector(selectedLength: .constant(.medium))
      .padding()
    
    Spacer()
  }
  .background(Color.gray.opacity(0.1))
}
