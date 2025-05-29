import SwiftUI

struct AppView: View {
    @State private var needsOnboarding: Bool = true
    @State private var isLoading: Bool = true
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var errorManager = ErrorManager()
    @EnvironmentObject var themeManager: ThemeManager
    
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
        Task {
            do {
                let profile = try StorageManager.shared.loadProfile()
                await MainActor.run {
                    needsOnboarding = profile == nil
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorManager.handleError(.dataCorruption)
                    needsOnboarding = true
                    isLoading = false
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
