import SwiftUI

struct GenderSelector: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "person.2.fill")
          .foregroundColor(.indigo)
          .font(.title3)
        Text("Gender")
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
        ForEach(Gender.allCases, id: \.self) { gender in
          Button(action: {
            viewModel.gender = gender
          }) {
            HStack(spacing: 8) {
              // Gender icon
              Image(systemName: genderIcon(for: gender))
                .font(.title3)
                .foregroundColor(viewModel.gender == gender ? .white : .primary)
              
              Text(gender.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(viewModel.gender == gender ? .white : .primary)
              
              Spacer()
              
              if viewModel.gender == gender {
                Image(systemName: "checkmark.circle.fill")
                  .font(.subheadline)
                  .foregroundColor(.white)
              }
            }
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 10)
                .fill(viewModel.gender == gender ?
                      LinearGradient(
                        gradient: Gradient(colors: [.indigo, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      ) :
                        LinearGradient(
                          gradient: Gradient(colors: [AppTheme.cardBackground.opacity(0.8), AppTheme.cardBackground.opacity(0.8)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                        )
                )
                .stroke(viewModel.gender == gender ?
                        Color.indigo :
                          AppTheme.defaultCardBorder, lineWidth: viewModel.gender == gender ? 2 : 1)
            )
          }
          .foregroundColor(.primary)
        }
      }
    }
  }
  
  // Helper function to return appropriate icon for each gender
  private func genderIcon(for gender: Gender) -> String {
    switch gender {
    case .male:
      return "person.fill"
    case .female:
      return "person.fill"
    case .notSpecified:
      return "questionmark.circle.fill"
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    GenderSelector(viewModel: OnboardingViewModel())
      .padding()
  }
}
