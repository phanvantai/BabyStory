import SwiftUI

struct StoryRecommendations: View {
  let recommendations: [String]
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "lightbulb.fill")
          .foregroundColor(.orange)
          .font(.title3)
        Text("onboarding_preferences_perfect_time_for".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
        ForEach(recommendations, id: \.self) { recommendation in
          HStack {
            Text(recommendation)
              .font(.subheadline)
              .fontWeight(.medium)
              .multilineTextAlignment(.leading)
            Spacer()
          }
          .padding(12)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.orange.opacity(0.1))
              .stroke(Color.orange.opacity(0.3), lineWidth: 1)
          )
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    StoryRecommendations(recommendations: [
      "Bedtime Stories", 
      "Calm Adventures", 
      "Dream Journeys", 
      "Goodnight Tales"
    ])
    .padding()
  }
}
