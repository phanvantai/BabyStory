//
//  WelcomHeader.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct WelcomeHeader: View {
  let name: String
  let subtitle: String
  @State private var showContent = false
  
  var body: some View {
    VStack(spacing: 16) {
      VStack(spacing: 8) {
        Text("Hello, \(name)! 👋")
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
    .onAppear {
      showContent = true
    }
  }
}

#Preview {
  WelcomeHeader(name: "Name", subtitle: "Subtitle goes here")
}
