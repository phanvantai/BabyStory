import SwiftUI

/// The root view of the application that handles app lifecycle, navigation flow,
/// and initial data loading. It manages three main states:
/// - Loading: Initial app data loading state
/// - Onboarding: First-time user setup flow
/// - Home: Main app experience after successful onboarding
struct AppView: View {
    // MARK: - State Properties
    /// Controls whether the onboarding flow should be displayed
    @State private var needsOnboarding: Bool = true
    /// Controls whether the loading screen should be displayed
    @State private var isLoading: Bool = true
    
    // MARK: - ViewModels
    /// ViewModel for the onboarding flow
    @StateObject private var onboardingVM = OnboardingViewModel()
    /// ViewModel for the home screen
    @StateObject private var homeVM = HomeViewModel()
    /// Centralized error handling manager
    @StateObject private var errorManager = ErrorManager()
    
    // MARK: - Environment
    /// Theme manager injected through environment
    @EnvironmentObject var themeManager: ThemeManager
    /// Current scene phase for handling app lifecycle events
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Body
    var body: some View {
        Group {
            // Conditional view rendering based on app state
            if isLoading {
                LoadingView()
            } else if needsOnboarding {
                OnboardingFlowView(onboardingVM: onboardingVM) {
                    needsOnboarding = false
                    homeVM.refresh()
                }
            } else {
                HomeView(viewModel: homeVM)
            }
        }
        .onAppear {
            loadInitialData()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Handle scene transitions more gracefully
            if newPhase == .active && oldPhase == .background {
                Logger.info("App became active from background - refreshing data", category: .general)
                // App became active from background - refresh data if needed
                if !needsOnboarding && !isLoading {
                    Task {
                        await MainActor.run {
                            homeVM.refresh()
                        }
                    }
                }
            }
        }
        // MARK: - Error Handling
        .alert("Error", isPresented: $errorManager.showError) {
            Button("OK") {
                errorManager.clearError()
            }
        } message: {
            if let error = errorManager.currentError {
                VStack(alignment: .leading, spacing: 8) {
                    Text(error.localizedDescription)
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                    }
                }
            }
        }
        .environmentObject(errorManager)
    }
    
    // MARK: - Private Methods
    /// Loads initial application data and determines whether to show onboarding
    /// or proceed directly to the home screen based on whether a user profile exists
    private func loadInitialData() {
        Logger.info("App starting - Loading initial data", category: .general)
        Task {
            // Add a small delay to avoid conflicts with app snapshot operations
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 second delay
            
            do {
                let profile = try StorageManager.shared.loadProfile()
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        needsOnboarding = profile == nil
                        isLoading = false
                    }
                    
                    if profile == nil {
                        Logger.info("No user profile found - showing onboarding", category: .general)
                    } else {
                        Logger.info("User profile exists - proceeding to home view", category: .general)
                        // Only refresh home view if we have a profile and are going to home
                        homeVM.refresh()
                    }
                }
            } catch {
                Logger.error("Failed to load initial data: \(error.localizedDescription)", category: .general)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        errorManager.handleError(.dataCorruption)
                        needsOnboarding = true
                        isLoading = false
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
                
                Text("Loading BabyStory...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
