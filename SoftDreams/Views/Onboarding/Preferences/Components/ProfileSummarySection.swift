import SwiftUI

struct ProfileSummarySection: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
          .font(.title2)
        Text("onboarding_preferences_profile_summary".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      VStack(spacing: 12) {
        ProfileSummaryRow(icon: "person.circle.fill", label: "onboarding_preferences_name".localized, value: viewModel.name.isEmpty ? "onboarding_preferences_not_set".localized : viewModel.name)
        ProfileSummaryRow(icon: "heart.circle.fill", label: "onboarding_preferences_stage".localized, value: viewModel.babyStage.displayName)
        ProfileSummaryRow(icon: "person.2.fill", label: "onboarding_preferences_gender".localized, value: viewModel.gender.displayName)
        ProfileSummaryRow(icon: "globe", label: "onboarding_preferences_language".localized, value: viewModel.selectedLanguage.nativeName)
        if !viewModel.isPregnancy {
          ProfileSummaryRow(icon: "calendar", label: "onboarding_preferences_age".localized, value: viewModel.ageDisplayText)
        }
        if !viewModel.interests.isEmpty {
          ProfileSummaryRow(icon: "star.circle.fill", label: "onboarding_preferences_interests".localized, value: "\(viewModel.interests.count) " + "onboarding_preferences_selected".localized)
        }
      }
      .padding(16)
      .appCardStyle()
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    ProfileSummarySection(viewModel: OnboardingViewModel())
      .padding()
  }
}
