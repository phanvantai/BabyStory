import SwiftUI

struct OnboardingPreferencesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onNext: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Story Time Preference")) {
                DatePicker("Preferred Story Time", selection: $viewModel.storyTime, displayedComponents: .hourAndMinute)
            }
            Button("Finish") {
                onNext()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
