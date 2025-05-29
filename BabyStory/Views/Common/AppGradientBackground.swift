//
//  AppGradientBackground.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct AppGradientBackground: View {
  let colors: [Color]
  let startPoint: UnitPoint
  let endPoint: UnitPoint
  
  init(
    colors: [Color] = [
      Color.purple.opacity(0.3),
      Color.blue.opacity(0.4),
      Color.cyan.opacity(0.3)
    ],
    startPoint: UnitPoint = .topLeading,
    endPoint: UnitPoint = .bottomTrailing
  ) {
    self.colors = colors
    self.startPoint = startPoint
    self.endPoint = endPoint
  }
  
  var body: some View {
    LinearGradient(
      gradient: Gradient(colors: colors),
      startPoint: startPoint,
      endPoint: endPoint
    )
    .ignoresSafeArea()
  }
}

#Preview {
  AppGradientBackground()
}
