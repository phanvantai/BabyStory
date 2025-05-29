//
//  OnboardingFlowView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

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

// MARK: - Preview
#Preview("Welcome Step") {
  OnboardingFlowView(
    onboardingVM: {
      let vm = OnboardingViewModel()
      vm.step = 0 // Welcome step
      return vm
    }()
  ) {
    print("Onboarding completed in preview")
  }
}

#Preview("Profile Step") {
  OnboardingFlowView(
    onboardingVM: {
      let vm = OnboardingViewModel()
      vm.step = 1 // Profile step
      return vm
    }()
  ) {
    print("Onboarding completed in preview")
  }
}

#Preview("Preferences Step") {
  OnboardingFlowView(
    onboardingVM: {
      let vm = OnboardingViewModel()
      vm.step = 2 // Preferences step
      // Set some sample data for a more realistic preview
      vm.name = "Emma"
      vm.babyStage = .toddler
      return vm
    }()
  ) {
    print("Onboarding completed in preview")
  }
}
