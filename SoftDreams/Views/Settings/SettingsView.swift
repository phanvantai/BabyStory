import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showEditProfile = false
  
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
    }
  }
}

// MARK: - Previews
#Preview {
  SettingsView(viewModel: SettingsViewModel())
    .environmentObject(ThemeManager.shared)
}
