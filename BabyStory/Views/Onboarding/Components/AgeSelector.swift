import SwiftUI

struct AgeSelector: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "calendar")
          .foregroundColor(.green)
          .font(.title3)
        Text("Age")
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
        
        // Show info for fixed ages
        if !viewModel.canEditAge {
          Text("Fixed")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(6)
        }
      }
      
      HStack {
        Button(action: viewModel.decreaseAge) {
          Image(systemName: "minus.circle.fill")
            .font(.title2)
            .foregroundColor(viewModel.canEditAge ? .purple : .gray)
        }
        .disabled(!viewModel.canEditAge)
        
        Spacer()
        
        Text(viewModel.ageDisplayText)
          .font(.title3)
          .fontWeight(.semibold)
          .frame(minWidth: 120)
        
        Spacer()
        
        Button(action: viewModel.increaseAge) {
          Image(systemName: "plus.circle.fill")
            .font(.title2)
            .foregroundColor(viewModel.canEditAge ? .purple : .gray)
        }
        .disabled(!viewModel.canEditAge)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(viewModel.canEditAge ? 
                AppTheme.cardBackground.opacity(0.8) : 
                  Color.gray.opacity(0.1))
          .stroke(viewModel.canEditAge ? 
                  AppTheme.defaultCardBorder : 
                    Color.gray.opacity(0.3), lineWidth: 1)
      )
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    AgeSelector(viewModel: OnboardingViewModel())
      .padding()
  }
}
