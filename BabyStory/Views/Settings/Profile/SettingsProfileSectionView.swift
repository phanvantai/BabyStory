//
//  SettingsProfileSectionView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct SettingsProfileSectionView: View {
  @EnvironmentObject var languageManager: LanguageManager
  @Binding var showEditProfile: Bool
  
  var body: some View {
    AnimatedEntrance(delay: 0.3) {
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "person.circle.fill")
            .foregroundColor(.blue)
            .font(.title3)
          Text("settings_profile_title".localized)
            .font(.headline)
            .fontWeight(.semibold)
          Spacer()
        }
        
        Button(action: { showEditProfile = true }) {
          HStack {
            Text("settings_profile_edit".localized)
              .font(.body)
              .fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right")
              .font(.caption)
              .foregroundColor(.secondary)
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
  SettingsProfileSectionView(showEditProfile: .constant(false))
}
