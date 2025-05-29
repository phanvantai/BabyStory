import SwiftUI

struct OnboardingProfileView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onNext: () -> Void
    @State private var interestsText: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Child's profile")) {
                TextField("Name", text: $viewModel.name)
                Stepper(value: $viewModel.age, in: 1...12) {
                    Text("Age: \(viewModel.age)")
                }
                TextField("Interests (comma separated)", text: $interestsText)
                    .onChange(of: interestsText) { newValue in
                        viewModel.interests = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    }
            }
            Button("Next") {
                if !interestsText.isEmpty {
                    viewModel.interests = interestsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                }
                onNext()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
