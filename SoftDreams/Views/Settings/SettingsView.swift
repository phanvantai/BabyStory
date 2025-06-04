import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showEditProfile = false
  @State private var showPremiumFeatures = false
  @State private var isRestoringPurchases = false
  
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
            
            // Premium Features Section
            SettingsPremiumSectionView(
                showPremiumFeatures: $showPremiumFeatures,
                isRestoringPurchases: $isRestoringPurchases
            )
            
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
  
  private func handleRestorePurchases() {
    isRestoringPurchases = true
    
    Task {
      do {
        try await ServiceFactory.shared.createStoreKitService().restorePurchases()
        await MainActor.run {
          isRestoringPurchases = false
        }
      } catch {
        await MainActor.run {
          isRestoringPurchases = false
          // Show error alert
//          viewModel.showError = true
//          viewModel.errorMessage = error.localizedDescription
        }
      }
    }
  }
}

// MARK: - Previews
#Preview {
  SettingsView(viewModel: SettingsViewModel())
    .environmentObject(ThemeManager.shared)
}
