import SwiftUI

struct LanguageSelector: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "globe")
          .foregroundColor(.blue)
          .font(.title3)
        Text("choose_language".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 1), spacing: 12) {
        ForEach(Language.allCases, id: \.self) { language in
          Button(action: {
            viewModel.selectedLanguage = language
          }) {
            HStack(spacing: 16) {
              // Language flag and name
              HStack(spacing: 12) {
                Text(language.flag)
                  .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                  Text(language.nativeName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.selectedLanguage == language ? .white : .primary)
                  
                  Text(language.name)
                    .font(.caption)
                    .foregroundColor(viewModel.selectedLanguage == language ? .white.opacity(0.8) : .secondary)
                }
              }
              
              Spacer()
              
              // Selection indicator
              if viewModel.selectedLanguage == language {
                Image(systemName: "checkmark.circle.fill")
                  .font(.title3)
                  .foregroundColor(.white)
              }
            }
            .padding(16)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.selectedLanguage == language ?
                      LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      ) :
                        LinearGradient(
                          gradient: Gradient(colors: [AppTheme.cardBackground.opacity(0.8), AppTheme.cardBackground.opacity(0.8)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                        )
                )
                .stroke(viewModel.selectedLanguage == language ?
                        Color.blue :
                          AppTheme.defaultCardBorder, lineWidth: viewModel.selectedLanguage == language ? 2 : 1)
            )
          }
          .foregroundColor(.primary)
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    LanguageSelector(viewModel: OnboardingViewModel())
      .padding()
  }
}
