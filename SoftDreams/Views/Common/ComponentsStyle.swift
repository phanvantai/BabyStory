//
//  ButtonStyle.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
  let colors: [Color]?
  let isEnabled: Bool
  
  init(colors: [Color]? = nil, isEnabled: Bool = true) {
    self.colors = colors
    self.isEnabled = isEnabled
  }
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .fontWeight(.semibold)
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(
        LinearGradient(
          gradient: Gradient(colors: isEnabled ? (colors ?? AppTheme.primaryButton) : [Color.gray, Color.gray.opacity(0.8)]),
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .cornerRadius(28)
      .shadow(color: isEnabled ? colors?.first?.opacity(0.3) ?? .clear : .clear, radius: 10, x: 0, y: 5)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

struct SecondaryButtonStyle: ButtonStyle {
  let backgroundColor: Color?
  let borderColor: Color?
  
  @Environment(\.colorScheme) private var colorScheme
  
  init(backgroundColor: Color? = nil, borderColor: Color? = nil) {
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
  }
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .fontWeight(.medium)
      .foregroundColor(.primary)
      .frame(maxWidth: .infinity)
      .frame(height: 48)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .fill(backgroundColor ?? Color(UIColor.systemBackground).opacity(0.9))
          .stroke(borderColor ?? Color.purple.opacity(0.3), lineWidth: 2)
      )
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

// MARK: - Done Button Style
struct DoneButtonStyle: ButtonStyle {
  let gradient: [Color]
  
  init(gradient: [Color] = [.blue, .purple]) {
    self.gradient = gradient
  }
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .fontWeight(.semibold)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(LinearGradient(
            gradient: Gradient(colors: gradient),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ))
          .opacity(configuration.isPressed ? 0.8 : 1.0)
      )
      .foregroundColor(.white)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .shadow(color: gradient.first?.opacity(0.3) ?? .clear, radius: 4, x: 0, y: 2)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

// MARK: - Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
  @Environment(\.colorScheme) private var colorScheme
  
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(UIColor.systemBackground).opacity(0.8))
          .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 1)
      )
  }
}
