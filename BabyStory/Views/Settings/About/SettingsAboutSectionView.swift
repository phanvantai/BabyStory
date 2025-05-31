//
//  SettingsAboutSectionView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct SettingsAboutSectionView: View {
  @ObservedObject var viewModel: SettingsViewModel
  
  var body: some View {
    AnimatedEntrance(delay: 1.0) {
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "info.circle.fill")
            .foregroundColor(.gray)
            .font(.title3)
          Text("settings_about_title".localized)
            .font(.headline)
            .fontWeight(.semibold)
          Spacer()
        }
        
        VStack(spacing: 8) {
          HStack {
            Text(viewModel.appName)
              .font(.body)
              .fontWeight(.medium)
            Spacer()
          }
          
          HStack {
            Text("settings_about_version".localized)
              .font(.body)
            Spacer()
            Text(viewModel.appVersion)
              .font(.body)
              .foregroundColor(.secondary)
          }
        }
      }
      .padding(20)
      .appCardStyle()
      .padding(.horizontal, 24)
    }
  }
}

#Preview {
  SettingsAboutSectionView(viewModel: SettingsViewModel())
}
