import SwiftUI

struct AppView: View {
    @State private var needsOnboarding: Bool = true
    @State private var isLoading: Bool = true
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var errorManager = ErrorManager()
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        Group {
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

struct LoadingView: View {
    var body: some View {
        ZStack {
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
