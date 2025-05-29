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
