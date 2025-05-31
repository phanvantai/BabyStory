//
//  EditProfileLanguageSelector.swift
//  BabyStory
//
//  Created by GitHub Copilot
//

import SwiftUI

struct EditProfileLanguageSelector: View {
  @ObservedObject var viewModel: EditProfileViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "globe")
          .foregroundColor(.blue)
          .font(.title3)
        Text("edit_profile_language_label".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 1), spacing: 12) {
        ForEach(Language.allCases, id: \.self) { language in
          Button(action: {
            viewModel.language = language
          }) {
            HStack(spacing: 16) {
              // Language flag and name
              HStack(spacing: 12) {
                Text(language.flag)
                  .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                  Text(language.nativeName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.language == language ? .white : .primary)
                  
                  Text(language.name)
                    .font(.caption)
                    .foregroundColor(viewModel.language == language ? .white.opacity(0.8) : .secondary)
                }
              }
              
              Spacer()
              
              // Selection indicator
              if viewModel.language == language {
                Image(systemName: "checkmark.circle.fill")
                  .font(.title3)
                  .foregroundColor(.white)
              }
            }
            .padding(16)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.language == language ?
                      LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      ) :
                        LinearGradient(
                          gradient: Gradient(colors: [AppTheme.cardBackground.opacity(0.8), AppTheme.cardBackground.opacity(0.8)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                        )
                )
                .stroke(viewModel.language == language ?
                        Color.blue :
                          AppTheme.defaultCardBorder, lineWidth: viewModel.language == language ? 2 : 1)
            )
          }
          .foregroundColor(.primary)
        }
      }
    }
  }
}

#Preview {
  EditProfileLanguageSelector(viewModel: EditProfileViewModel())
    .environmentObject(ThemeManager.shared)
}
