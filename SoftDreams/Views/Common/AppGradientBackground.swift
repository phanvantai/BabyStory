//
//  AppGradientBackground.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct AppGradientBackground: View {
  let colors: [Color]?
  let startPoint: UnitPoint
  let endPoint: UnitPoint
  @Environment(\.colorScheme) private var colorScheme
  
  init(
    colors: [Color]? = nil,
    startPoint: UnitPoint = .topLeading,
    endPoint: UnitPoint = .bottomTrailing
  ) {
    self.colors = colors
    self.startPoint = startPoint
    self.endPoint = endPoint
  }
  
  var body: some View {
    LinearGradient(
      gradient: Gradient(colors: effectiveColors),
      startPoint: startPoint,
      endPoint: endPoint
    )
    .ignoresSafeArea()
  }
  
  private var effectiveColors: [Color] {
    if let colors = colors {
      return colors
    }
    
    // Use theme-aware colors based on color scheme
    return colorScheme == .dark ? AppTheme.appGradientColorsDark : AppTheme.appGradientColors
  }
}

#Preview {
  AppGradientBackground()
}
