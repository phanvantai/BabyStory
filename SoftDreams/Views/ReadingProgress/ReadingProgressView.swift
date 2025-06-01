//
//  ReadingProgressView.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct ReadingProgressView: View {
  let profile: UserProfile?
  
  var body: some View {
    ZStack {
      AppGradientBackground()
      
      VStack(spacing: 20) {
        Text("Reading Progress")
          .font(.largeTitle)
          .fontWeight(.bold)
        
        Text("Coming Soon!")
          .font(.title2)
          .foregroundColor(.secondary)
        
        Text("Track your little one's reading journey, favorite stories, and milestones.")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  ReadingProgressView(profile: nil)
}
