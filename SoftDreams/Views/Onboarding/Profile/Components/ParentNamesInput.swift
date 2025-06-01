import SwiftUI

struct ParentNamesInput: View {
  @ObservedObject var viewModel: OnboardingViewModel
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "figure.2.and.child.holdinghands")
          .foregroundColor(.orange)
          .font(.title3)
        Text("profile_parent_names_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
        
        if viewModel.parentNames.count < 2 {
          Button(action: viewModel.addParentName) {
            Image(systemName: "plus.circle.fill")
              .foregroundColor(.purple)
              .font(.title3)
          }
        }
      }
      
      ForEach(Array(viewModel.parentNames.enumerated()), id: \.offset) { index, name in
        HStack {
          TextField(String(format: "profile_parent_name_placeholder".localized, index + 1), text: $viewModel.parentNames[index])
            .textFieldStyle(CustomTextFieldStyle())
          
          if viewModel.parentNames.count > 1 {
            Button(action: {
              viewModel.removeParentName(at: index)
            }) {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
                .font(.title3)
            }
          }
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    ParentNamesInput(viewModel: {
      let vm = OnboardingViewModel()
      vm.parentNames = [String(format: "profile_parent_name_placeholder".localized, 1)]
      return vm
    }())
    .padding()
  }
}
