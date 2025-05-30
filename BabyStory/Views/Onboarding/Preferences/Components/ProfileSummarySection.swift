import SwiftUI

struct ProfileSummarySection: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
          .font(.title2)
        Text("Profile Summary")
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      VStack(spacing: 12) {
        ProfileSummaryRow(icon: "person.circle.fill", label: "Name", value: viewModel.name.isEmpty ? "Not set" : viewModel.name)
        ProfileSummaryRow(icon: "heart.circle.fill", label: "Stage", value: viewModel.babyStage.displayName)
        ProfileSummaryRow(icon: "person.2.fill", label: "Gender", value: viewModel.gender.displayName)
        ProfileSummaryRow(icon: "globe.fill", label: "Language", value: viewModel.selectedLanguage.nativeName)
        if !viewModel.isPregnancy {
          ProfileSummaryRow(icon: "calendar", label: "Age", value: viewModel.ageDisplayText)
        }
        if !viewModel.interests.isEmpty {
          ProfileSummaryRow(icon: "star.circle.fill", label: "Interests", value: "\(viewModel.interests.count) selected")
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
