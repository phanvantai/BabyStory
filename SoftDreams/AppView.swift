import SwiftUI

/// The root view of the application that handles app lifecycle, navigation flow,
/// and initial data loading. It manages three main states:
/// - Loading: Initial app data loading state
/// - Onboarding: First-time user setup flow
/// - Home: Main app experience after successful onboarding
struct AppView: View {
  // MARK: - ViewModels
  /// Main app state management ViewModel
  @EnvironmentObject var appViewModel: AppViewModel
  /// ViewModel for the onboarding flow
  @StateObject private var onboardingVM = OnboardingViewModel()
  /// ViewModel for the home screen
  @StateObject private var homeVM = HomeViewModel()
  
  // MARK: - Environment
  /// Theme manager injected through environment
  @EnvironmentObject var themeManager: ThemeManager
  /// Current scene phase for handling app lifecycle events
  @Environment(\.scenePhase) private var scenePhase
  
  // MARK: - Body
  var body: some View {
    Group {
      // Conditional view rendering based on app state
      if appViewModel.isLoading {
        LoadingView()
      } else if appViewModel.needsOnboarding {
        OnboardingFlowView(onboardingVM: onboardingVM) {
          Task {
            await appViewModel.onboardingComplete()
            homeVM.refresh()
          }
        }
      } else {
        HomeView(viewModel: homeVM)
          .onAppear {
            // Ensure HomeViewModel data is loaded when first showing HomeView
            if homeVM.profile == nil {
              homeVM.refresh()
            }
          }
      }
    }
    .onAppear {
      Task {
        await appViewModel.loadInitialData()
      }
    }
    .onChange(of: scenePhase) { oldPhase, newPhase in
      Task {
        await appViewModel.handleScenePhaseChange(from: oldPhase, to: newPhase)
        // Handle home refresh if needed
        if newPhase == .active && oldPhase == .background && !appViewModel.needsOnboarding && !appViewModel.isLoading {
          homeVM.refresh()
          // Check and reset daily story count when app becomes active
          appViewModel.checkAndResetDailyCount()
        }
      }
    }
    // MARK: - Error Handling
    .alert("Error", isPresented: .constant(appViewModel.currentError != nil)) {
      Button("OK") {
        appViewModel.clearError()
      }
    } message: {
      if let error = appViewModel.currentError {
        VStack(alignment: .leading, spacing: 8) {
          Text(error.localizedDescription)
          if let suggestion = error.recoverySuggestion {
            Text(suggestion)
              .font(.caption)
          }
        }
      }
    }
  }
}

/// A simple loading view displayed during initial app data loading
struct LoadingView: View {
  var body: some View {
    ZStack {
      // Apply the app's gradient background
      AppGradientBackground()
      
      VStack(spacing: 20) {
        ProgressView()
          .scaleEffect(1.5)
        
        Text("app_loading_title".localized)
          .font(.headline)
          .foregroundColor(.secondary)
      }
    }
  }
}
