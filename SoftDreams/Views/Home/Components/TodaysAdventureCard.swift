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
      case 5..<12:
        return "sunrise.fill"
      case 12..<17:
        return "sun.max.fill"
      case 17..<20:
        return "sunset.fill"
      default:
        return "moon.stars.fill"
    }
  }
  
  private var timeOfDayColor: Color {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
      case 5..<12:
        return .orange
      case 12..<17:
        return .yellow
      case 17..<20:
        return .pink
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
      
      if let config = appViewModel.storyGenerationConfig {
        if !config.canGenerateNewStory {
          HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.orange)
            Text("home_story_limit_reached".localized)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .padding(.vertical, 8)
          .padding(.horizontal, 12)
          .background(Color.orange.opacity(0.1))
          .cornerRadius(8)
        } else if config.storiesRemainingToday == 1 {
          HStack(spacing: 8) {
            Image(systemName: "sparkles")
              .foregroundColor(.purple)
            Text("home_one_story_remaining".localized)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .padding(.vertical, 8)
          .padding(.horizontal, 12)
          .background(Color.purple.opacity(0.1))
          .cornerRadius(8)
        }
      }
      
      Button(action: {
        // Check if user is free tier and at limit
        if let config = appViewModel.storyGenerationConfig,
           !config.canGenerateNewStory,
           config.subscriptionTier == .free {
          storyGenVM.showPaywall = true
          return
        }
        
        Task {
          if let profile = homeVM.profile,
             let story = await storyGenVM.generateTodaysStory(profile: profile, appViewModel: appViewModel) {
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
    .sheet(isPresented: $storyGenVM.showPaywall) {
      if let config = appViewModel.storyGenerationConfig {
        PaywallView(
          onClose: { storyGenVM.showPaywall = false },
          onUpgrade: {
            // The AppViewModel will automatically detect subscription changes
            storyGenVM.showPaywall = false
          },
          config: config,
          storeKitService: appViewModel.storeKitService
        )
      }
    }
  }
}

#Preview {
  TodaysAdventureCard(
    storyGenVM: StoryGenerationViewModel(),
    homeVM: HomeViewModel(),
    onStoryGenerated: { _ in }
  )
}
