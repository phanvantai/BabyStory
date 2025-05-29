import SwiftUI

struct OnboardingDescriptionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Create magical bedtime stories")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Personalized adventures that spark imagination and create lasting memories for your little one")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        OnboardingDescriptionView()
    }
}
