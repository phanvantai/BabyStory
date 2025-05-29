import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel
  @State private var showEditProfile = false
  @State private var showParentalLock = false
  
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
                }
                .buttonStyle(PlainButtonStyle())
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
              .padding(20)
              .appCardStyle()
              .padding(.horizontal, 24)
            }
            
            // Parental Controls Section
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
                }
                .buttonStyle(PlainButtonStyle())
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
                    Text("Version")
                      .font(.body)
                    Spacer()
                    Text("1.0.0")
                      .font(.body)
                      .foregroundColor(.secondary)
                  }
                  
                  HStack {
                    Text("Build")
                      .font(.body)
                    Spacer()
                    Text("1")
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
      .sheet(isPresented: $showParentalLock) {
        ParentalLockView(viewModel: viewModel)
      }
    }
  }
}
