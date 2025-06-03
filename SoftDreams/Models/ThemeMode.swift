//
//  ThemeMode.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 4/6/25.
//

import Foundation

// MARK: - Theme Mode Enum
enum ThemeMode: String, CaseIterable, Codable {
  case system = "system"
  case light = "light"
  case dark = "dark"
  
  var displayName: String {
    switch self {
    case .system:
      return "theme_mode_system".localized
    case .light:
      return "theme_mode_light".localized
    case .dark:
      return "theme_mode_dark".localized
    }
  }
  
  var icon: String {
    switch self {
    case .system:
      return "gear"
    case .light:
      return "sun.max.fill"
    case .dark:
      return "moon.fill"
    }
  }
}
