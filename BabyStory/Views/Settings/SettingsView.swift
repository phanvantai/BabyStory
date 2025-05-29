import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showEditProfile = false
    @State private var showParentalLock = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile")) {
                    Button("Edit Profile") { showEditProfile = true }
                }
                Section(header: Text("Preferences")) {
                    Toggle("Voice/Narration", isOn: $viewModel.narrationEnabled)
                }
                Section(header: Text("Parental Controls")) {
                    Button("Parental Lock") { showParentalLock = true }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showEditProfile) {
                Text("Edit Profile Screen (TODO)")
            }
            .sheet(isPresented: $showParentalLock) {
                ParentalLockView(viewModel: viewModel)
            }
        }
    }
}
