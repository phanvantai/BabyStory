import SwiftUI

struct AppView: View {
    @State private var needsOnboarding: Bool = UserDefaultsManager.shared.loadProfile() == nil
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var homeVM = HomeViewModel()
    
    var body: some View {
        if needsOnboarding {
            OnboardingFlowView(onboardingVM: onboardingVM) {
                needsOnboarding = false
                homeVM.refresh()
            }
        } else {
            HomeView(viewModel: homeVM)
        }
    }
}

// Wrapper for onboarding steps
struct OnboardingFlowView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            switch onboardingVM.step {
            case 0:
                OnboardingWelcomeView(viewModel: onboardingVM) {
                    onboardingVM.step = 1
                }
            case 1:
                OnboardingProfileView(viewModel: onboardingVM) {
                    onboardingVM.step = 2
                }
            case 2:
                OnboardingPreferencesView(viewModel: onboardingVM) {
                    onboardingVM.saveProfile()
                    onComplete()
                }
            default:
                EmptyView()
            }
        }
    }
}
