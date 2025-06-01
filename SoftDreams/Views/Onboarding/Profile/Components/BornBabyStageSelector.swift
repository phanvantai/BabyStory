import SwiftUI

struct BornBabyStageSelector: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  private var availableStages: [BabyStage] {
    // Exclude pregnancy from the options since user already chose "born baby"
    return BabyStage.allCases.filter { $0 != .pregnancy }
  }
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "figure.child.circle.fill")
          .foregroundColor(.blue)
          .font(.title3)
        Text("profile_baby_age_stage_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
        ForEach(availableStages, id: \.self) { stage in
          Button(action: {
            viewModel.updateBabyStage(stage)
          }) {
            VStack(spacing: 8) {
              Text(stage.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.babyStage == stage ? .primary : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
              
              Text(stage.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80) // Fixed height for consistent sizing
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.babyStage == stage ?
                      Color.blue.opacity(0.2) :
                        AppTheme.cardBackground.opacity(0.8))
                .stroke(viewModel.babyStage == stage ?
                        Color.blue :
                          AppTheme.defaultCardBorder, lineWidth: 2)
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
    BornBabyStageSelector(viewModel: {
      let vm = OnboardingViewModel()
      vm.updateBabyStage(.toddler) // Set to non-pregnancy stage for preview
      return vm
    }())
    .padding()
  }
}
