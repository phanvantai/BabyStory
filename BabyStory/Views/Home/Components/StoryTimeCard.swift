import SwiftUI

struct StoryTimeCard: View {
    let storyTime: Date
    let storiesCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.purple)
                    .font(.title3)
                Text("Story Time")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next story time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(storyTime, style: .time)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Stories read")
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
    }
}

#Preview {
    StoryTimeCard(storyTime: Date(), storiesCount: 12)
}
