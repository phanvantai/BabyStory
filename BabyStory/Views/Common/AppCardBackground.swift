//
//  AppCardBackground.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct AppCardBackground: ViewModifier {
  let backgroundColor: Color
  let borderColor: Color
  let shadowColor: Color
  
  init(
    backgroundColor: Color = Color.white.opacity(0.9),
    borderColor: Color = Color.gray.opacity(0.2),
    shadowColor: Color = Color.black.opacity(0.1)
  ) {
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.shadowColor = shadowColor
  }
  
  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(backgroundColor)
          .stroke(borderColor, lineWidth: 1)
          .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
      )
  }
}

extension View {
  func appCardStyle(
    backgroundColor: Color = Color.white.opacity(0.9),
    borderColor: Color = Color.gray.opacity(0.2),
    shadowColor: Color = Color.black.opacity(0.1)
  ) -> some View {
    self.modifier(AppCardBackground(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      shadowColor: shadowColor
    ))
  }
}

#Preview {
  VStack(spacing: 20) {
    // Default card style
    VStack {
      Text("Default Card Style")
        .font(.headline)
      Text("This is a sample card with default styling")
        .font(.body)
        .foregroundColor(.secondary)
    }
    .padding()
    .appCardStyle()
    
    // Custom colored card
    VStack {
      Text("Custom Card Style")
        .font(.headline)
      Text("This card uses custom colors")
        .font(.body)
        .foregroundColor(.secondary)
    }
    .padding()
    .appCardStyle(
      backgroundColor: Color.blue.opacity(0.1),
      borderColor: Color.blue.opacity(0.3),
      shadowColor: Color.blue.opacity(0.2)
    )
    
    // Story card example
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        Text("The Magic Forest")
          .font(.title2)
          .fontWeight(.semibold)
        Text("A wonderful adventure awaits...")
          .font(.body)
          .foregroundColor(.secondary)
        
        HStack {
          Text("5 min read")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .clipShape(Capsule())
          
          Spacer()
          
          Text("⭐ Favorite")
            .font(.caption)
            .foregroundColor(.orange)
        }
      }
      
      Spacer()
      
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.purple.opacity(0.3))
        .frame(width: 60, height: 60)
        .overlay(
          Text("📚")
            .font(.title)
        )
    }
    .padding()
    .appCardStyle()
  }
  .padding()
  .background(
    LinearGradient(
      gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)]),
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  )
}
