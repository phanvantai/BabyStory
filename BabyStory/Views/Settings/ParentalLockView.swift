import SwiftUI

struct ParentalLockView: View {
  @ObservedObject var viewModel: SettingsViewModel
  @State private var passcode: String = ""
  @State private var message: String?
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      ZStack {
        AppGradientBackground()
        FloatingStars(count: 8)
        
        VStack(spacing: 32) {
          Spacer()
          
          // Lock Icon and Title
          AnimatedEntrance(delay: 0.1) {
            VStack(spacing: 16) {
              Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
              
              GradientText(
                "Parental Lock",
                colors: [.orange, .red]
              )
              .font(.title)
              .fontWeight(.bold)
              
              Text("Enter your 4-digit passcode")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          }
          
          // Passcode Input
          AnimatedEntrance(delay: 0.3) {
            VStack(spacing: 20) {
              SecureField("Enter passcode", text: $passcode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .onChange(of: passcode) { oldValue, newValue in
                  if newValue.count > 4 {
                    passcode = String(newValue.prefix(4))
                  }
                }
              
              // Status display
              HStack {
                Image(systemName: viewModel.parentalLockEnabled ? "lock.fill" : "lock.open.fill")
                  .foregroundColor(viewModel.parentalLockEnabled ? .red : .green)
                
                Text(viewModel.parentalLockEnabled ? "Lock is ON" : "Lock is OFF")
                  .font(.headline)
                  .foregroundColor(viewModel.parentalLockEnabled ? .red : .green)
              }
              .padding(16)
              .appCardStyle()
            }
          }
          
          // Action Button
          AnimatedEntrance(delay: 0.5) {
            VStack(spacing: 16) {
              Button(action: {
                if viewModel.toggleParentalLock(passcode: passcode) {
                  message = viewModel.parentalLockEnabled ? "Lock Enabled Successfully" : "Lock Disabled Successfully"
                  passcode = ""
                } else {
                  message = "Incorrect Passcode"
                }
              }) {
                Text(viewModel.parentalLockEnabled ? "Disable Lock" : "Enable Lock")
                  .font(.headline)
                  .fontWeight(.semibold)
              }
              .buttonStyle(PrimaryButtonStyle(
                colors: viewModel.parentalLockEnabled ? [.green, .mint] : [.orange, .red]
              ))
              .disabled(passcode.count != 4)
              
              if let message = message {
                Text(message)
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(message.contains("Incorrect") ? .red : .green)
                  .padding(.horizontal)
                  .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                      self.message = nil
                    }
                  }
              }
            }
          }
          
          Spacer()
          
          // Instructions
          AnimatedEntrance(delay: 0.7) {
            VStack(spacing: 8) {
              Text("About Parental Lock")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
              
              Text("When enabled, this prevents children from accessing settings or making changes to the app.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            .padding(16)
            .appCardStyle(
              backgroundColor: AppTheme.cardBackground.opacity(0.1),
              borderColor: AppTheme.defaultCardBorder
            )
            .padding(.horizontal, 24)
          }
        }
        .padding(.horizontal, 24)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Done") {
            dismiss()
          }
          .buttonStyle(DoneButtonStyle())
        }
      }
    }
  }
}

#Preview {
  // Mock SettingsViewModel for preview
  class MockSettingsViewModel: SettingsViewModel {
    override init() {
      super.init()
      // Set initial state for preview
      self.parentalLockEnabled = false
    }
    
    override func toggleParentalLock(passcode: String) -> Bool {
      // Mock implementation for preview
      if passcode == "1234" {
        parentalLockEnabled.toggle()
        return true
      }
      return false
    }
  }
  
  return ParentalLockView(viewModel: MockSettingsViewModel())
}
