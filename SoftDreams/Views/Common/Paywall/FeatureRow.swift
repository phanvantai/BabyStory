//
//  FeatureRow.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 4/6/25.
//

import SwiftUI

struct FeatureRow: View {
  let icon: String
  let text: String
  
  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 32, height: 32)
        
        Image(systemName: icon)
          .foregroundStyle(
            LinearGradient(
              gradient: Gradient(colors: [Color.purple, Color.pink]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .font(.system(size: 14))
      }
      
      Text(text)
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 4)
  }
}
