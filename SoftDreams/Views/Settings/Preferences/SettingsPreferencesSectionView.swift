//
//  SettingsPreferencesSectionView.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct SettingsPreferencesSectionView: View {
  @EnvironmentObject var languageManager: LanguageManager
  @ObservedObject var viewModel: SettingsViewModel
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    AnimatedEntrance(delay: 0.5) {
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "slider.horizontal.3")
            .foregroundColor(.green)
            .font(.title3)
          Text("settings_preferences_title".localized)
            .font(.headline)
            .fontWeight(.semibold)
          Spacer()
        }
        
        VStack(spacing: 16) {
          // Theme Picker
          ThemePicker(onThemeChanged: {
            dismiss()
          })
          
          // Language Picker
          Divider()
            .background(Color(UIColor.separator))
          
          LanguagePicker()
          
          // Auto-Update Settings Navigation
          Divider()
            .background(Color(UIColor.separator))
          
          NavigationLink(destination: AutoUpdateSettingsView(viewModel: AutoUpdateSettingsViewModel())) {
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text("settings_auto_update_profile_title".localized)
                  .font(.body)
                  .fontWeight(.medium)
                Text("settings_auto_update_profile_description".localized)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              Spacer()
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
          }
          .buttonStyle(PlainButtonStyle())
        }
      }
      .padding(20)
      .appCardStyle()
      .padding(.horizontal, 24)
    }
  }
}

#Preview {
  SettingsPreferencesSectionView(viewModel: SettingsViewModel())
    .environmentObject(ThemeManager.shared)
}
