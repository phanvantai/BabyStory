//
//  ThemePicker.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct ThemePicker: View {
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "paintbrush.fill")
          .foregroundColor(.blue)
          .font(.title3)
        Text("App Theme")
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      VStack(spacing: 12) {
        ForEach(ThemeMode.allCases, id: \.self) { theme in
          Button(action: {
            guard theme != themeManager.currentTheme else { return }
            themeManager.currentTheme = theme
          }) {
            HStack(spacing: 16) {
              // Theme icon with background
              ZStack {
                RoundedRectangle(cornerRadius: 12)
                  .fill(themeManager.currentTheme == theme ?
                        LinearGradient(
                          gradient: Gradient(colors: [Color.blue, Color.purple]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                        ) :
                          LinearGradient(
                            gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemBackground)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                  )
                  .frame(width: 44, height: 44)
                  .overlay(
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(themeManager.currentTheme == theme ? Color.blue : Color(UIColor.separator).opacity(0.3), lineWidth: themeManager.currentTheme == theme ? 2 : 1)
                  )
                
                Image(systemName: theme.icon)
                  .font(.title3)
                  .foregroundColor(themeManager.currentTheme == theme ? .white : .primary)
              }
              
              // Theme info
              VStack(alignment: .leading, spacing: 4) {
                Text(theme.displayName)
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(.primary)
                
                Text(themeDescription(for: theme))
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              // Selection indicator
              if themeManager.currentTheme == theme {
                Image(systemName: "checkmark.circle.fill")
                  .font(.title3)
                  .foregroundColor(.blue)
              } else {
                Image(systemName: "circle")
                  .font(.title3)
                  .foregroundColor(.gray.opacity(0.4))
              }
            }
            .padding(16)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.currentTheme == theme ? Color.blue.opacity(0.1) : Color(UIColor.systemBackground).opacity(0.5))
                .stroke(themeManager.currentTheme == theme ? Color.blue.opacity(0.3) : Color(UIColor.separator).opacity(0.3), lineWidth: 1)
            )
          }
          .buttonStyle(PlainButtonStyle())
          .scaleEffect(themeManager.currentTheme == theme ? 1.02 : 1.0)
          .animation(.easeInOut(duration: 0.2), value: themeManager.currentTheme)
        }
      }
    }
  }
  
  private func themeDescription(for theme: ThemeMode) -> String {
    switch theme {
    case .system:
      return "Follows your device setting"
    case .light:
      return "Always use light appearance"
    case .dark:
      return "Always use dark appearance"
    }
  }
}

#Preview {
  VStack {
    ThemePicker()
      .environmentObject(ThemeManager.shared)
      .padding()
    
    Spacer()
  }
  .background(Color.gray.opacity(0.1))
}
