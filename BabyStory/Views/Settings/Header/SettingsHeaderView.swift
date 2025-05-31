//
//  SettingsHeaderView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct SettingsHeaderView: View {
  var body: some View {
    AnimatedEntrance(delay: 0.1) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          GradientText(
            "Settings",
            colors: [.purple, .blue]
          )
          .font(.largeTitle)
          .fontWeight(.bold)
          
          Text("Customize your experience")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        Spacer()
        
        Image(systemName: "gear.circle.fill")
          .font(.title)
          .foregroundColor(.purple)
      }
      .padding(.horizontal, 24)
      .padding(.top, 20)
    }
  }
}

#Preview {
  SettingsHeaderView()
}
