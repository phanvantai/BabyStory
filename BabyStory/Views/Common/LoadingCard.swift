//
//  LoadingCard.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct LoadingCard: View {
  let message: String
  
  init(message: String = "Loading...") {
    self.message = message
  }
  
  var body: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.2)
        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
      
      Text(message)
        .font(.body)
        .foregroundColor(.secondary)
    }
    .padding(32)
    .appCardStyle()
  }
}

#Preview {
  LoadingCard()
}
