import SwiftUI

struct StoryTimeDisplay: View {
  @Binding var storyTime: Date
  var onTap: () -> Void
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "moon.stars.fill")
          .foregroundColor(.purple)
          .font(.title2)
        Text("onboarding_preferences_story_time".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      // Time display
      HStack {
        Spacer()
        VStack(spacing: 4) {
          Text("onboarding_preferences_bedtime_stories_at".localized)
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Text(storyTime, style: .time)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(
              LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.pink]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
        }
        Spacer()
      }
      .padding(.vertical, 20)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(AppTheme.cardBackground.opacity(0.9))
          .stroke(Color.purple.opacity(0.3), lineWidth: 2)
          .shadow(color: .purple.opacity(0.1), radius: 8, x: 0, y: 4)
      )
      .onTapGesture {
        onTap()
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    StoryTimeDisplay(
      storyTime: .constant(Date()),
      onTap: {}
    )
    .padding()
  }
}
