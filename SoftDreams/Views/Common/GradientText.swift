//
//  GradientText.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct GradientText: View {
  let text: String
  let font: Font
  let colors: [Color]
  
  init(
    _ text: String,
    font: Font = .largeTitle,
    colors: [Color] = [Color.purple, Color.pink, Color.orange]
  ) {
    self.text = text
    self.font = font
    self.colors = colors
  }
  
  var body: some View {
    Text(text)
      .font(font)
      .foregroundStyle(
        LinearGradient(
          gradient: Gradient(colors: colors),
          startPoint: .leading,
          endPoint: .trailing
        )
      )
  }
}

#Preview {
  GradientText("Gradient Text")
}
