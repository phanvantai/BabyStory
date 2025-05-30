import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  @State private var showEditProfile = false
  @State private var showParentalLock = false
  
  // App info from service
  private let appInfo = AppInfoService.shared
  
  // Feature flags for future implementation
  private let showVoiceNarration = false // TODO: Enable when implementing voice narration
  private let showParentalControls = false // TODO: Enable when implementing parental controls
  
  var body: some View {
    NavigationStack {
      ZStack {
        AppGradientBackground()
        FloatingStars(count: 10)
        
        ScrollView {
          VStack(spacing: 24) {
            // Header
            AnimatedEntrance(delay: 0.1) {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  GradientText(
                    "Settings",
                    colors: [.purple, .blue]
                  )
                  .font(.largeTitle)
                  .fontWeight(.bold)
                  
                  Text("Customize your experience")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                Spacer()
                
                Image(systemName: "gear.circle.fill")
                  .font(.title)
                  .foregroundColor(.purple)
              }
              .padding(.horizontal, 24)
              .padding(.top, 20)
            }
            
            // Profile Section
            AnimatedEntrance(delay: 0.3) {
              VStack(spacing: 16) {
                HStack {
                  Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                  Text("Profile")
                    .font(.headline)
                    .fontWeight(.semibold)
                  Spacer()
                }
                
                Button(action: { showEditProfile = true }) {
                  HStack {
                    Text("Edit Profile")
                      .font(.body)
                      .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }
                  .padding(.vertical, 12)
                  .contentShape(Rectangle())
                }
              }
              .padding(20)
              .appCardStyle()
              .padding(.horizontal, 24)
            }
            
            // Preferences Section
            AnimatedEntrance(delay: 0.5) {
              VStack(spacing: 16) {
                HStack {
                  Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.green)
                    .font(.title3)
                  Text("Preferences")
                    .font(.headline)
                    .fontWeight(.semibold)
                  Spacer()
                }
                
                VStack(spacing: 16) {
                  // Theme Picker
                  ThemePicker(onThemeChanged: {
                    dismiss()
                  })
                  
                  // Auto-Update Settings Navigation
                  Divider()
                    .background(Color(UIColor.separator))
                  
                  NavigationLink(destination: AutoUpdateSettingsView(viewModel: AutoUpdateSettingsViewModel())) {
                    HStack {
                      VStack(alignment: .leading, spacing: 4) {
                        Text("Auto-Update Profile")
                          .font(.body)
                          .fontWeight(.medium)
                        Text("Manage automatic profile updates as your child grows")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      }
                      Spacer()
                      Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                  }
                  .buttonStyle(PlainButtonStyle())
                  
                  // Voice Narration Toggle (temporarily hidden)
                  if showVoiceNarration {
                    Divider()
                      .background(Color(UIColor.separator))
                    
                    HStack {
                      VStack(alignment: .leading, spacing: 4) {
                        Text("Voice Narration")
                          .font(.body)
                          .fontWeight(.medium)
                        Text("Enable story read-aloud")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      }
                      Spacer()
                      Toggle("", isOn: $viewModel.narrationEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    .padding(.vertical, 8)
                  }
                }
              }
              .padding(20)
              .appCardStyle()
              .padding(.horizontal, 24)
            }
            
            // Parental Controls Section (temporarily hidden)
            if showParentalControls {
              AnimatedEntrance(delay: 0.7) {
                VStack(spacing: 16) {
                  HStack {
                    Image(systemName: "lock.shield.fill")
                      .foregroundColor(.orange)
                      .font(.title3)
                    Text("Parental Controls")
                      .font(.headline)
                      .fontWeight(.semibold)
                    Spacer()
                  }
                  
                  Button(action: { showParentalLock = true }) {
                    HStack {
                      VStack(alignment: .leading, spacing: 4) {
                        Text("Parental Lock")
                          .font(.body)
                          .fontWeight(.medium)
                        Text("Manage access and restrictions")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      }
                      Spacer()
                      Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                  }
                }
                .padding(20)
                .appCardStyle()
                .padding(.horizontal, 24)
              }
            }
            
            // Support Section
            AnimatedEntrance(delay: 0.8) {
              VStack(spacing: 16) {
                HStack {
                  Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.teal)
                    .font(.title3)
                  Text("Support")
                    .font(.headline)
                    .fontWeight(.semibold)
                  Spacer()
                }
                
                Button(action: { viewModel.openSupportWebsite() }) {
                  HStack {
                    VStack(alignment: .leading, spacing: 4) {
                      Text("Get Help")
                        .font(.body)
                        .fontWeight(.medium)
                      Text("Visit our support website")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                      .font(.body)
                      .foregroundColor(.teal)
                  }
                  .padding(.vertical, 12)
                  .contentShape(Rectangle())
                }
              }
              .padding(20)
              .appCardStyle()
              .padding(.horizontal, 24)
            }
            
            // App Info Section
            AnimatedEntrance(delay: 0.9) {
              VStack(spacing: 16) {
                HStack {
                  Image(systemName: "info.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
                  Text("About")
                    .font(.headline)
                    .fontWeight(.semibold)
                  Spacer()
                }
                
                VStack(spacing: 8) {
                  HStack {
                    Text(appInfo.appName)
                      .font(.body)
                      .fontWeight(.medium)
                    Spacer()
                  }
                  
                  HStack {
                    Text("Version")
                      .font(.body)
                    Spacer()
                    Text(appInfo.appVersion)
                      .font(.body)
                      .foregroundColor(.secondary)
                  }
                }
              }
              .padding(20)
              .appCardStyle()
              .padding(.horizontal, 24)
            }
            
            Spacer(minLength: 100)
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showEditProfile) {
        EditProfileView()
      }
      // Sheet for parental lock (accessible when feature is enabled)
      .sheet(isPresented: $showParentalLock) {
        ParentalLockView(viewModel: viewModel)
      }
      // Use preferredColorScheme from ThemeManager
      .preferredColorScheme(themeManager.preferredColorScheme)
    }
  }
}

// MARK: - Previews
#Preview {
  SettingsView(viewModel: SettingsViewModel())
    .environmentObject(ThemeManager.shared)
}
