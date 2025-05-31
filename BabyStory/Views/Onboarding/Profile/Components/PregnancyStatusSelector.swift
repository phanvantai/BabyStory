import SwiftUI

struct PregnancyStatusSelector: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  private var isPregnancySelected: Bool {
    return viewModel.hasSelectedBabyStatus && viewModel.isPregnancy
  }
  
  private var isBornBabySelected: Bool {
    return viewModel.hasSelectedBabyStatus && !viewModel.isPregnancy
  }
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "heart.circle.fill")
          .foregroundColor(.pink)
          .font(.title3)
        Text("baby_status_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      VStack(spacing: 12) {
        // Pregnancy option
        Button(action: {
          viewModel.updateBabyStage(.pregnancy)
        }) {
          HStack(spacing: 12) {
            Image(systemName: "heart.fill")
              .font(.title2)
              .foregroundColor(isPregnancySelected ? .white : .pink)
            
            VStack(alignment: .leading, spacing: 4) {
              Text("baby_status_pregnant".localized)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isPregnancySelected ? .white : .primary)
              
              Text("baby_status_pregnant_description".localized)
                .font(.caption)
                .foregroundColor(isPregnancySelected ? .white.opacity(0.8) : .secondary)
                .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            if isPregnancySelected {
              Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.white)
            }
          }
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(isPregnancySelected ?
                    LinearGradient(
                      gradient: Gradient(colors: [.pink, .purple]),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    ) :
                      LinearGradient(
                        gradient: Gradient(colors: [AppTheme.cardBackground.opacity(0.8), AppTheme.cardBackground.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      )
              )
              .stroke(isPregnancySelected ?
                      Color.pink :
                        AppTheme.defaultCardBorder, lineWidth: isPregnancySelected ? 2 : 1)
          )
        }
        .foregroundColor(.primary)
        
        // Born baby option
        Button(action: {
          // Set to toddler as default, user can change this later in baby stage selector
          viewModel.updateBabyStage(.toddler)
        }) {
          HStack(spacing: 12) {
            Image(systemName: "figure.child.circle.fill")
              .font(.title2)
              .foregroundColor(isBornBabySelected ? .white : .blue)
            
            VStack(alignment: .leading, spacing: 4) {
              Text("baby_status_born".localized)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isBornBabySelected ? .white : .primary)
              
              Text("baby_status_born_description".localized)
                .font(.caption)
                .foregroundColor(isBornBabySelected ? .white.opacity(0.8) : .secondary)
                .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            if isBornBabySelected {
              Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.white)
            }
          }
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(isBornBabySelected ?
                    LinearGradient(
                      gradient: Gradient(colors: [.blue, .cyan]),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    ) :
                      LinearGradient(
                        gradient: Gradient(colors: [AppTheme.cardBackground.opacity(0.8), AppTheme.cardBackground.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      )
              )
              .stroke(isBornBabySelected ?
                      Color.blue :
                        AppTheme.defaultCardBorder, lineWidth: isBornBabySelected ? 2 : 1)
          )
        }
        .foregroundColor(.primary)
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    PregnancyStatusSelector(viewModel: OnboardingViewModel())
      .padding()
  }
}
