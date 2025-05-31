//
//  SettingsSupportSectionView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct SettingsSupportSectionView: View {
  @ObservedObject var viewModel: SettingsViewModel
  
  var body: some View {
    AnimatedEntrance(delay: 0.9) {
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "questionmark.circle.fill")
            .foregroundColor(.teal)
            .font(.title3)
          Text("settings_support_title".localized)
            .font(.headline)
            .fontWeight(.semibold)
          Spacer()
        }
        
        Button(action: { viewModel.openSupportWebsite() }) {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("settings_support_get_help".localized)
                .font(.body)
                .fontWeight(.medium)
              Text("settings_support_description".localized)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right.square")
              .font(.body)
              .foregroundColor(.teal)
          }
          .padding(.vertical, 12)
          .contentShape(Rectangle())
        }
      }
      .padding(20)
      .appCardStyle()
      .padding(.horizontal, 24)
    }
  }
}

#Preview {
  SettingsSupportSectionView(viewModel: SettingsViewModel())
}
