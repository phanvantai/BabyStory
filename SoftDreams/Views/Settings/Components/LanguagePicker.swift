//
//  LanguagePicker.swift
//  SoftDreams
//
//  Created by Tai Phan Van
//

import SwiftUI

struct LanguagePicker: View {
  @StateObject private var viewModel = LanguagePickerViewModel()
  @EnvironmentObject var languageManager: LanguageManager
  
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
            Task {
              await viewModel.selectLanguage(language)
            }
          }) {
            HStack {
              Text(language.displayName)
              if viewModel.selectedLanguage == language {
                Spacer()
                Image(systemName: "checkmark")
              }
            }
          }
        }
      } label: {
        HStack {
          Text(viewModel.selectedLanguage.displayName)
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
      
      // Show error message if any
      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
          .font(.caption)
          .foregroundColor(.red)
          .onAppear {
            // Auto-clear error after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
              viewModel.clearError()
            }
          }
      }
    }
  }
}

#Preview {
  LanguagePicker()
    .environmentObject(LanguageManager.shared)
    .padding()
}
