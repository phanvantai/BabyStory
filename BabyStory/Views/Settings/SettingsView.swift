import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  @State private var showEditProfile = false
  @State private var showParentalLock = false
  
  // Feature flag for future implementation
  private let showParentalControls = false // TODO: Enable when implementing parental controls
  
  var body: some View {
    NavigationStack {
      ZStack {
        AppGradientBackground()
        FloatingStars(count: 10)
        
        ScrollView {
          VStack(spacing: 24) {
            // Header
            SettingsHeaderView()
            
            // Profile Section
            SettingsProfileSectionView(showEditProfile: $showEditProfile)
            
            // Preferences Section
            SettingsPreferencesSectionView(viewModel: viewModel)
            
            // Notifications Section
            SettingsNotificationsSectionView(viewModel: viewModel)
            
            // Parental Controls Section (temporarily hidden)
            if showParentalControls {
              SettingsParentalControlsSectionView(showParentalLock: $showParentalLock)
            }
            
            // Support Section
            SettingsSupportSectionView(viewModel: viewModel)
            
            // App Info Section
            SettingsAboutSectionView(viewModel: viewModel)
            
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
