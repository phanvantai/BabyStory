import SwiftUI

struct OnboardingWelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Baby Story")
                .font(.largeTitle)
                .bold()
            Text("Brief app explanation")
                .font(.body)
                .foregroundColor(.secondary)
            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
