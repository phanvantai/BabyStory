//
//  ThemeManager.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI
import UIKit

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
  static let shared = ThemeManager()
  
  // MARK: - Dependencies
  private let themeService: ThemeServiceProtocol
  
  @Published var currentTheme: ThemeMode {
    didSet {
      // Only update if theme actually changed
      guard oldValue != currentTheme else { return }
      themeService.saveTheme(currentTheme) // Save theme to persistent storage
      updateColorScheme()
    }
  }
  
  @Published var preferredColorScheme: ColorScheme?
  
  // MARK: - Initializers
  
  /// Initialize with default theme service (for shared instance)
  convenience init() {
    self.init(themeService: ServiceFactory.shared.createThemeService())
  }
  
  /// Initialize with custom theme service (for dependency injection and testing)
  /// - Parameter themeService: The theme service to use for persistence
  init(themeService: ThemeServiceProtocol) {
    self.themeService = themeService
    
    // Load saved theme from theme service
    self.currentTheme = themeService.loadTheme()
    
    // Update color scheme based on loaded theme
    updateColorScheme()
    
    // Register for system appearance changes
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(systemAppearanceChanged),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    // Also listen for user interface style changes (better for system theme detection)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(systemAppearanceChanged),
      name: Notification.Name("UIUserInterfaceStyleDidChangeNotification"),
      object: nil
    )
  }
  
  deinit {
    // Clean up notification observer
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public Methods
  
  /// Handle system appearance changes (exposed for testing)
  func handleSystemAppearanceChange() {
    systemAppearanceChanged()
  }
  
  // MARK: - Private Methods
  
  @objc private func systemAppearanceChanged() {
    // When the app becomes active, update the color scheme only if using system theme
    // Add a small delay to avoid conflicts with snapshot operations
    guard currentTheme == .system else { return }
    
    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
      updateColorScheme()
    }
  }
  
  private func updateColorScheme() {
    // Use main actor to ensure UI updates are on main thread
    Task { @MainActor in
      // Update color scheme with animation to reduce jarring transitions
      withAnimation(.easeInOut(duration: 0.3)) {
        switch self.currentTheme {
        case .system:
          // For system theme, we're setting preferredColorScheme to nil
          // This tells SwiftUI to use the system's color scheme
          self.preferredColorScheme = nil
        case .light:
          self.preferredColorScheme = .light
        case .dark:
          self.preferredColorScheme = .dark
        }
      }
    }
  }
}

// MARK: - Theme Colors
struct AppTheme {
  
  // MARK: - Environment-aware color access
  static func primaryBackground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.black.opacity(0.05) : Color.primary.opacity(0.02)
  }
  
  static func secondaryBackground(for colorScheme: ColorScheme) -> Color {
    Color(UIColor.secondarySystemBackground)
  }
  
  static func cardBackground(for colorScheme: ColorScheme) -> Color {
    Color(UIColor.systemBackground)
  }
  
  // MARK: - Static accessors for compatibility
  static var primaryBackground: Color {
    Color.primary.opacity(0.02)
  }
  
  static var secondaryBackground: Color {
    Color(UIColor.secondarySystemBackground)
  }
  
  static var cardBackground: Color {
    Color(UIColor.systemBackground)
  }
  
  // MARK: - Gradient Backgrounds
  static var appGradientColors: [Color] {
    [
      Color.purple.opacity(0.3),
      Color.blue.opacity(0.4),
      Color.cyan.opacity(0.3)
    ]
  }
  
  static var appGradientColorsDark: [Color] {
    [
      Color.purple.opacity(0.15),
      Color.blue.opacity(0.2),
      Color.cyan.opacity(0.15)
    ]
  }
  
  // MARK: - Card Styles
  static var defaultCardBackground: Color {
    Color(UIColor.systemBackground).opacity(0.9)
  }
  
  static var defaultCardBorder: Color {
    Color(UIColor.separator).opacity(0.3)
  }
  
  static var defaultCardShadow: Color {
    Color.black.opacity(0.1)
  }
  
  // MARK: - Text Colors
  static var primaryText: Color {
    Color.primary
  }
  
  static var secondaryText: Color {
    Color.secondary
  }
  
  static var accentText: Color {
    Color.purple
  }
  
  // MARK: - Action Colors
  static var primaryButton: [Color] {
    [Color.purple, Color.pink]
  }
  
  static var secondaryButton: Color {
    Color(UIColor.systemBackground).opacity(0.9)
  }
  
  static var secondaryButtonBorder: Color {
    Color.purple.opacity(0.3)
  }
}

// MARK: - Environment Key for Theme
private struct ThemeManagerKey: EnvironmentKey {
  static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
  var themeManager: ThemeManager {
    get { self[ThemeManagerKey.self] }
    set { self[ThemeManagerKey.self] = newValue }
  }
}
