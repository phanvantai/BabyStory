import SwiftUI

struct NameInputField: View {
  @Binding var name: String
  let iconName: String
  let iconColor: Color
  let label: String
  let placeholder: String
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: iconName)
          .foregroundColor(iconColor)
          .font(.title3)
        Text(label)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      TextField(placeholder, text: $name)
        .textFieldStyle(CustomTextFieldStyle())
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    NameInputField(
      name: .constant(""),
      iconName: "textformat.abc",
      iconColor: .cyan,
      label: "onboarding_profile_baby_name_label".localized,
      placeholder: "onboarding_profile_baby_name_placeholder".localized
    )
    .padding()
  }
}
