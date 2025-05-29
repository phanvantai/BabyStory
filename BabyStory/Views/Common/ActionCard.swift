//
//  ActionCard.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct ActionCard: View {
  let title: String
  let subtitle: String
  let icon: String
  let gradientColors: [Color]
  let action: () -> Void
  
  @State private var isPressed = false
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 16) {
        // Icon
        ZStack {
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 60, height: 60)
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
          
          Image(systemName: icon)
            .font(.system(size: 28))
            .foregroundColor(.white)
        }
        
        // Text
        VStack(spacing: 4) {
          Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(1)
          
          Text(subtitle)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: 50) // Fixed height for text area
      }
      .frame(height: 140) // Fixed total height for consistent card sizing
      .frame(maxWidth: .infinity) // Ensure full width usage
      .padding(20)
    }
    .buttonStyle(PlainButtonStyle())
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(AppTheme.cardBackground.opacity(0.5))
        .stroke(AppTheme.defaultCardBorder, lineWidth: 1)
        .shadow(color: AppTheme.defaultCardShadow, radius: 8, x: 0, y: 4)
    )
    .scaleEffect(isPressed ? 0.95 : 1.0)
    .animation(.easeInOut(duration: 0.1), value: isPressed)
    .onTapGesture {
      isPressed = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isPressed = false
        action()
      }
    }
  }
}

#Preview {
  ActionCard(title: "Title", subtitle: "This is subtitle", icon: "", gradientColors: [Color.cyan, Color.green]) {
    print("Action triggered")
  }
}
