//
//  AppIcon.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 12/6/25.
//

import Foundation
import UIKit

// MARK: - App Icon Enum
enum AppIcon: String, CaseIterable, Identifiable {
  case liquidGlass  = "AppIcon"
  case classic      = "AppIconClassic"
  
  var id: String { self.rawValue }
  
  var displayName: String {
    switch self {
    case .liquidGlass:
      return "app_icon_liquid_glass_name".localized
    case .classic:
      return "app_icon_normal_name".localized
    }
  }
  
  var description: String {
    switch self {
    case .liquidGlass:
      return "app_icon_liquid_glass_description".localized
    case .classic:
      return "app_icon_normal_description".localized
    }
  }
  
  var icon: String {
    switch self {
    case .liquidGlass:
      return "drop.triangle"
    case .classic:
      return "app.badge"
    }
  }
  
  /// The actual icon name used by UIApplication.setAlternateIconName
  /// nil for primary icon, string for alternate icons
  var iconName: String? {
    switch self {
    case .liquidGlass:
      return nil // Primary icon (AppIcon)
    case .classic:
      return "AppIconClassic"
    }
  }
}
