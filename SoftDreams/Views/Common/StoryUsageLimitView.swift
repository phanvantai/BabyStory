import SwiftUI

struct StoryUsageLimitView: View {
  let storiesGenerated: Int
  let dailyLimit: Int
  let tier: SubscriptionTier
  
  private var progressValue: CGFloat {
    guard dailyLimit > 0 else { return 0 }
    return min(1.0, CGFloat(storiesGenerated) / CGFloat(dailyLimit))
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("story_usage_title".localized)
          .font(.headline)
          .foregroundStyle(.primary)
        
        Spacer()
        
        Text(String(format: "story_usage_count".localized, storiesGenerated, dailyLimit))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      
      // Progress bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          // Background
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 10)
          
          // Foreground progress
          RoundedRectangle(cornerRadius: 10)
            .fill(progressColor)
            .frame(width: geometry.size.width * progressValue, height: 10)
        }
      }
      .frame(height: 10)
      
      // Subscription tier indicator
      HStack {
        Spacer()
        
        Text(tier == .free ? "story_usage_free_plan".localized : "story_usage_premium_plan".localized)
          .font(.caption)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(
            RoundedRectangle(cornerRadius: 6)
              .fill(tier == .free ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
          )
      }
    }
    .padding(.vertical, 8)
  }
  
  private var progressColor: Color {
    let value = progressValue
    if value < 0.5 {
      return .green
    } else if value < 0.8 {
      return .yellow
    } else {
      return .red
    }
  }
}

#Preview("Free - Low Usage") {
  StoryUsageLimitView(storiesGenerated: 1, dailyLimit: 3, tier: .free)
    .padding()
}

#Preview("Free - Medium Usage") {
  StoryUsageLimitView(storiesGenerated: 2, dailyLimit: 3, tier: .free)
    .padding()
}

#Preview("Free - Max Usage") {
  StoryUsageLimitView(storiesGenerated: 3, dailyLimit: 3, tier: .free)
    .padding()
}

#Preview("Premium - Medium Usage") {
  StoryUsageLimitView(storiesGenerated: 5, dailyLimit: 10, tier: .premium)
    .padding()
}
