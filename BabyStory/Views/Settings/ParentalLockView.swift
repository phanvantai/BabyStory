import SwiftUI

struct ParentalLockView: View {
  @ObservedObject var viewModel: SettingsViewModel
  @State private var passcode: String = ""
  @State private var message: String?
  @State private var isMessageError: Bool = false
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
                "parental_lock_title".localized,
                colors: [.orange, .red]
              )
              .font(.title)
              .fontWeight(.bold)
              
              Text("parental_lock_enter_passcode".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          }
          
          // Passcode Input
          AnimatedEntrance(delay: 0.3) {
            VStack(spacing: 20) {
              SecureField("parental_lock_enter_passcode_placeholder".localized, text: $passcode)
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
                
                Text(viewModel.parentalLockEnabled ? "parental_lock_on".localized : "parental_lock_off".localized)
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
                  message = viewModel.parentalLockEnabled ? "parental_lock_enabled_success".localized : "parental_lock_disabled_success".localized
                  isMessageError = false
                  passcode = ""
                } else {
                  message = "parental_lock_incorrect_passcode".localized
                  isMessageError = true
                }
              }) {
                Text(viewModel.parentalLockEnabled ? "parental_lock_disable".localized : "parental_lock_enable".localized)
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
                  .foregroundColor(isMessageError ? .red : .green)
                  .padding(.horizontal)
                  .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                      self.message = nil
                      self.isMessageError = false
                    }
                  }
              }
            }
          }
          
          Spacer()
          
          // Instructions
          AnimatedEntrance(delay: 0.7) {
            VStack(spacing: 8) {
              Text("parental_lock_about_title".localized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
              
              Text("parental_lock_about_description".localized)
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
          Button("done".localized) {
            dismiss()
          }
          .buttonStyle(DoneButtonStyle())          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
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
