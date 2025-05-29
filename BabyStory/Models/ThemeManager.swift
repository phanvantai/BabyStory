//
//  ThemeManager.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI
import UIKit

// MARK: - Theme Mode Enum
enum ThemeMode: String, CaseIterable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
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

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ThemeMode {
        didSet {
            UserDefaultsManager.shared.saveTheme(currentTheme)
            updateColorScheme()
        }
    }
    
    @Published var preferredColorScheme: ColorScheme?
    
    init() {
        // Load saved theme from UserDefaultsManager
        self.currentTheme = UserDefaultsManager.shared.loadTheme()
        updateColorScheme()
        
        // Register for system appearance changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemAppearanceChanged),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func systemAppearanceChanged() {
        // When the app becomes active, update the color scheme
        // This catches system theme changes while the app is in background
        if currentTheme == .system {
            updateColorScheme()
        }
    }
    
    private func updateColorScheme() {
        DispatchQueue.main.async {
            // Update color scheme immediately without animation
            switch self.currentTheme {
            case .system:
                // For system theme, we're setting preferredColorScheme to nil
                // This tells SwiftUI to use the system's color scheme
                self.preferredColorScheme = nil
                
                // Post a notification that can be observed at the app level to refresh
                NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
            case .light:
                self.preferredColorScheme = .light
                
                // Post a notification that can be observed at the app level to refresh
                NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
            case .dark:
                self.preferredColorScheme = .dark
                
                // Post a notification that can be observed at the app level to refresh
                NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
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
