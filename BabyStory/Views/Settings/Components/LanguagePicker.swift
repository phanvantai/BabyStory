//
//  LanguagePicker.swift
//  BabyStory
//
//  Created by GitHub Copilot
//

import SwiftUI

struct LanguagePicker: View {
  @EnvironmentObject var languageManager: LanguageManager
  
  private var selectedLanguage: Language {
    Language.allCases.first { $0.code == languageManager.currentLanguage } ?? Language.preferred
  }
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "globe")
          .foregroundColor(.blue)
          .font(.title3)
        Text("settings_language_title".localized)
          .font(.body)
          .fontWeight(.medium)
        Spacer()
      }
      
      Menu {
        ForEach(Language.allCases, id: \.self) { language in
          Button(action: {
            selectLanguage(language)
          }) {
            HStack {
              Text(language.displayName)
              if selectedLanguage == language {
                Spacer()
                Image(systemName: "checkmark")
              }
            }
          }
        }
      } label: {
        HStack {
          Text(selectedLanguage.displayName)
            .foregroundColor(.primary)
          Spacer()
          Image(systemName: "chevron.up.chevron.down")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(AppTheme.defaultCardBorder, lineWidth: 1)
        )
      }
    }
  }
  
  private func selectLanguage(_ language: Language) {
    // Update LanguageManager for immediate UI changes
    languageManager.updateLanguage(language.code)
    
    // Update UserProfile if it exists
    Task {
      await updateProfileLanguage(language)
    }
  }
  
  @MainActor
  private func updateProfileLanguage(_ language: Language) async {
    do {
      if var profile = try StorageManager.shared.loadProfile() {
        profile.language = language
        try StorageManager.shared.saveProfile(profile)
        Logger.info("Profile language updated to: \(language.code)", category: .userProfile)
      }
    } catch {
      Logger.error("Failed to update profile language: \(error.localizedDescription)", category: .userProfile)
    }
  }
}

#Preview {
  LanguagePicker()
    .environmentObject(LanguageManager.shared)
    .padding()
}
