//
//  LoadingCard.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct LoadingCard: View {
  let message: String
  
  init(message: String = "loading_default_message".localized) {
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
