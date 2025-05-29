//
//  FloatingStars.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct FloatingStars: View {
  let count: Int
  @State private var isAnimating = false
  
  init(count: Int = 12) {
    self.count = count
  }
  
  var body: some View {
    GeometryReader { geometry in
      ForEach(0..<count, id: \.self) { index in
        Circle()
          .fill(Color.yellow.opacity(0.6))
          .frame(width: CGFloat.random(in: 3...8))
          .position(
            x: CGFloat.random(in: 0...geometry.size.width),
            y: CGFloat.random(in: 0...geometry.size.height)
          )
          .scaleEffect(isAnimating ? 1 : 0.5)
          .animation(
            .easeInOut(duration: Double.random(in: 2...4))
            .delay(Double.random(in: 0...2))
            .repeatForever(autoreverses: true),
            value: isAnimating
          )
      }
    }
    .onAppear {
      isAnimating = true
    }
  }
}

#Preview {
  FloatingStars()
}
