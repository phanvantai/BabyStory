import SwiftUI

struct DateOfBirthPicker: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "calendar")
          .foregroundColor(.green)
          .font(.title3)
        Text("Date of Birth")
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
        
        // Show current age if date is selected
        if viewModel.dateOfBirth != nil {
          Text(viewModel.ageDisplayText)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(6)
        }
      }
      
      DatePicker(
        "",
        selection: Binding(
          get: { viewModel.dateOfBirth ?? Date() },
          set: { viewModel.dateOfBirth = $0 }
        ),
        in: viewModel.dateOfBirthRange,
        displayedComponents: .date
      )
      .datePickerStyle(.compact)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(AppTheme.cardBackground.opacity(0.8))
          .stroke(AppTheme.defaultCardBorder, lineWidth: 1)
      )
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    DateOfBirthPicker(viewModel: OnboardingViewModel())
      .padding()
  }
}
