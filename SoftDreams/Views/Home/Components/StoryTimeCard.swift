import SwiftUI

struct StoryTimeCard: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    let storyTime: Date
    let storiesCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.purple)
                    .font(.title3)
                Text("home_story_time".localized)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("home_next_story_time".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(storyTime, style: .time)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("home_stories_read".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(storiesCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(20)
        .appCardStyle()
        .id(languageManager.currentLanguage) // Force refresh when language changes
    }
}

#Preview {
    StoryTimeCard(storyTime: Date(), storiesCount: 12)
}
