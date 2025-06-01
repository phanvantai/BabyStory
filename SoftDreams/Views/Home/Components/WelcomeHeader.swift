import SwiftUI

struct WelcomeHeader: View {
  let name: String
  let subtitle: String
  @ObservedObject private var languageManager = LanguageManager.shared
  @State private var showContent = false
  
  var body: some View {
    VStack(spacing: 16) {
      VStack(spacing: 8) {
        Text(String(format: "home_hello_greeting".localized, name))
          .font(.system(size: 32, weight: .bold, design: .rounded))
          .foregroundStyle(
            LinearGradient(
              gradient: Gradient(colors: [Color.purple, Color.pink, Color.orange]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .multilineTextAlignment(.center)
        
        Text(subtitle)
          .font(.title3)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
      .opacity(showContent ? 1 : 0)
      .offset(y: showContent ? 0 : 20)
      .animation(.easeOut(duration: 0.8).delay(0.2), value: showContent)
    }
    .id(languageManager.currentLanguage) // Force refresh when language changes
    .onAppear {
      showContent = true
    }
  }
}

#Preview {
    WelcomeHeader(
        name: "Emma",
        subtitle: "home_ready_for_adventure".localized
    )
}
