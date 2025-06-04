import SwiftUI

struct TodaysAdventureCard: View {
  @ObservedObject var storyGenVM: StoryGenerationViewModel
  @ObservedObject var homeVM: HomeViewModel
  @EnvironmentObject var appViewModel: AppViewModel
  @ObservedObject private var languageManager = LanguageManager.shared
  let onStoryGenerated: (Story) -> Void
  
  private var timeOfDayIcon: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
      case 6..<10:
        return "sunrise.fill"
      case 10..<16:
        return "sun.max.fill"
      case 16..<21:
        return "sunset.fill"
      default:
        return "moon.stars.fill"
    }
  }
  
  private var timeOfDayColor: Color {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
      case 6..<12:
        return .orange
      case 12..<18:
        return .yellow
      case 18..<21:
        return .orange
      default:
        return .purple
    }
  }
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: timeOfDayIcon)
          .foregroundColor(timeOfDayColor)
          .font(.title2)
        Text("home_todays_adventure".localized)
          .font(.title2)
          .fontWeight(.bold)
        Spacer()
      }
      
      Button(action: {
        homeVM.generateTodaysStory(using: storyGenVM, appViewModel: appViewModel) { story in
          if let story = story {
            onStoryGenerated(story)
          }
        }
      }) {
        HStack(spacing: 12) {
          Text("home_create_todays_story".localized)
            .font(.headline)
            .fontWeight(.semibold)
          
          Image(systemName: "sparkles")
            .font(.title3)
        }
      }
      .buttonStyle(PrimaryButtonStyle(colors: [Color.orange, Color.pink]))
      .disabled(storyGenVM.isGenerating)
      
      if storyGenVM.isGenerating {
        HStack {
          ProgressView()
            .scaleEffect(0.8)
          Text("home_creating_magical_story".localized)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(20)
    .appCardStyle(
      backgroundColor: timeOfDayColor.opacity(0.1),
      borderColor: timeOfDayColor.opacity(0.3),
      shadowColor: timeOfDayColor.opacity(0.2)
    )
    .id(languageManager.currentLanguage) // Force refresh when language changes
  }
}

#Preview {
  TodaysAdventureCard(
    storyGenVM: StoryGenerationViewModel(),
    homeVM: HomeViewModel(),
    onStoryGenerated: { _ in }
  )
}
