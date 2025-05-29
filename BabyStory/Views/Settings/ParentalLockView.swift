import SwiftUI

struct ParentalLockView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var passcode: String = ""
    @State private var message: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Enter Parental Passcode")
                .font(.headline)
            SecureField("Passcode", text: $passcode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            Button("Toggle Lock") {
                if viewModel.toggleParentalLock(passcode: passcode) {
                    message = viewModel.parentalLockEnabled ? "Lock Enabled" : "Lock Disabled"
                } else {
                    message = "Incorrect Passcode"
                }
            }
            .buttonStyle(.borderedProminent)
            if let message = message {
                Text(message)
                    .foregroundColor(message == "Incorrect Passcode" ? .red : .green)
            }
        }
        .padding()
    }
}
