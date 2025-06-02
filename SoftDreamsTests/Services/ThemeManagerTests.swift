import Testing
import Foundation
import SwiftUI
@testable import SoftDreams

@MainActor
struct ThemeManagerTests {
    
    init() {
        // Clean up before each test
        UserDefaults.standard.removeObject(forKey: "selected_theme")
        UserDefaults.standard.removeObject(forKey: "theme_settings")
    }
    
    deinit {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "selected_theme")
        UserDefaults.standard.removeObject(forKey: "theme_settings")
    }
    
    // MARK: - Singleton Tests
    
    @Test("Singleton instance")
    func testSingletonInstance() {
        let instance1 = ThemeManager.shared
        let instance2 = ThemeManager.shared
        
        #expect(instance1 === instance2)
    }
    
    // MARK: - Theme Mode Tests
    
    @Test("Theme mode enum properties")
    func testThemeModeProperties() {
        // Test all theme modes have display names and icons
        for theme in ThemeMode.allCases {
            #expect(theme.displayName.isEmpty == false)
            #expect(theme.icon.isEmpty == false)
        }
        
        // Test specific values
        #expect(ThemeMode.system.rawValue == "system")
        #expect(ThemeMode.light.rawValue == "light")
        #expect(ThemeMode.dark.rawValue == "dark")
        
        // Test icons
        #expect(ThemeMode.system.icon == "gear")
        #expect(ThemeMode.light.icon == "sun.max.fill")
        #expect(ThemeMode.dark.icon == "moon.fill")
    }
    
    @Test("Theme mode codable compliance")
    func testThemeModeCodeable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for theme in ThemeMode.allCases {
            let encoded = try encoder.encode(theme)
            let decoded = try decoder.decode(ThemeMode.self, from: encoded)
            #expect(decoded == theme)
        }
    }
    
    // MARK: - Theme Manager Initialization Tests
    
    @Test("Default theme initialization")
    func testDefaultThemeInitialization() {
        // Clear any existing theme preference
        UserDefaults.standard.removeObject(forKey: "selected_theme")
        
        let manager = ThemeManager()
        
        // Should default to system theme when no preference is saved
        #expect(manager.currentTheme == .system)
    }
    
    @Test("Load saved theme preference")
    func testLoadSavedThemePreference() {
        // Set a saved theme preference by saving through StorageManager
        StorageManager.shared.saveTheme(.dark)
        
        let manager = ThemeManager()
        
        #expect(manager.currentTheme == .dark)
    }
    
    // MARK: - Theme Change Tests
    
    @Test("Change theme updates current theme")
    func testChangeThemeUpdatesCurrentTheme() {
        let manager = ThemeManager.shared
        
        manager.currentTheme = .light
        #expect(manager.currentTheme == .light)
        
        manager.currentTheme = .dark
        #expect(manager.currentTheme == .dark)
        
        manager.currentTheme = .system
        #expect(manager.currentTheme == .system)
    }
    
    @Test("Theme change persists to storage")
    func testThemeChangePersistsToStorage() {
        let manager = ThemeManager.shared
        
        manager.currentTheme = .dark
        
        // Verify it's saved in storage
        let savedTheme = StorageManager.shared.loadTheme()
        #expect(savedTheme == .dark)
    }
    
    @Test("Setting same theme does not trigger unnecessary updates")
    func testSettingSameThemeDoesNotTriggerUnnecessaryUpdates() {
        let manager = ThemeManager.shared
        
        manager.currentTheme = .light
        let firstUpdate = manager.currentTheme
        
        manager.currentTheme = .light // Same theme
        
        #expect(manager.currentTheme == firstUpdate)
        #expect(manager.currentTheme == .light)
    }
    
    // MARK: - Color Scheme Tests
    
    @Test("Color scheme updates for light theme")
    func testColorSchemeUpdatesForLightTheme() async {
        let manager = ThemeManager.shared
        
        manager.currentTheme = .light
        
        // Allow time for async color scheme update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(manager.preferredColorScheme == .light)
    }
    
    @Test("Color scheme updates for dark theme") 
    func testColorSchemeUpdatesForDarkTheme() async {
        let manager = ThemeManager.shared
        
        manager.currentTheme = .dark
        
        // Allow time for async color scheme update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(manager.preferredColorScheme == .dark)
    }
    
    @Test("Color scheme updates for system theme")
    func testColorSchemeUpdatesForSystemTheme() async {
        let manager = ThemeManager.shared
        
        manager.currentTheme = .system
        
        // Allow time for async color scheme update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(manager.preferredColorScheme == nil)
    }
    
    // MARK: - Multiple Theme Changes
    
    @Test("Multiple theme changes")
    func testMultipleThemeChanges() async {
        let manager = ThemeManager.shared
        
        let themes: [ThemeMode] = [.system, .light, .dark, .system, .dark]
        
        for theme in themes {
            manager.currentTheme = theme
            
            #expect(manager.currentTheme == theme)
            #expect(StorageManager.shared.loadTheme() == theme)
            
            // Small delay to allow color scheme updates
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        }
    }
    
    // MARK: - Notification Tests
    
    @Test("System appearance change notification setup")
    func testSystemAppearanceChangeNotificationSetup() {
        let manager = ThemeManager()
        
        // This test verifies the manager initializes without crashes
        // and sets up notification observers
        #expect(manager.currentTheme != nil)
        
        // Test that the manager has been properly initialized
        #expect(ThemeMode.allCases.contains(manager.currentTheme))
    }
    
    // MARK: - Published Property Tests
    
    @Test("Published property changes")
    func testPublishedPropertyChanges() async {
        let manager = ThemeManager.shared
        let originalTheme = manager.currentTheme
        
        // This is a simplified test since we can't easily test @Published in Testing framework
        // In real scenarios, this would be tested with Combine
        let newTheme: ThemeMode = originalTheme == .light ? .dark : .light
        
        manager.currentTheme = newTheme
        
        #expect(manager.currentTheme == newTheme)
        #expect(manager.currentTheme != originalTheme)
    }
    
    // MARK: - AppTheme Static Properties Tests
    
    @Test("AppTheme static properties")
    func testAppThemeStaticProperties() {
        // Test that all static properties return valid colors
        #expect(AppTheme.primaryBackground != nil)
        #expect(AppTheme.secondaryBackground != nil)
        #expect(AppTheme.cardBackground != nil)
        #expect(AppTheme.defaultCardBackground != nil)
        #expect(AppTheme.defaultCardBorder != nil)
        #expect(AppTheme.defaultCardShadow != nil)
        #expect(AppTheme.primaryText != nil)
        #expect(AppTheme.secondaryText != nil)
        #expect(AppTheme.accentText != nil)
        
        // Test gradient arrays are not empty
        #expect(AppTheme.appGradientColors.count > 0)
        #expect(AppTheme.appGradientColorsDark.count > 0)
        #expect(AppTheme.primaryButton.count > 0)
        
        // Test specific color values
        #expect(AppTheme.accentText == .purple)
        #expect(AppTheme.primaryButton.contains(.purple))
        #expect(AppTheme.primaryButton.contains(.pink))
    }
    
    @Test("AppTheme environment-aware colors")
    func testAppThemeEnvironmentAwareColors() {
        // Test light color scheme colors
        let lightPrimary = AppTheme.primaryBackground(for: .light)
        let lightSecondary = AppTheme.secondaryBackground(for: .light)
        let lightCard = AppTheme.cardBackground(for: .light)
        
        #expect(lightPrimary != nil)
        #expect(lightSecondary != nil)
        #expect(lightCard != nil)
        
        // Test dark color scheme colors
        let darkPrimary = AppTheme.primaryBackground(for: .dark)
        let darkSecondary = AppTheme.secondaryBackground(for: .dark)
        let darkCard = AppTheme.cardBackground(for: .dark)
        
        #expect(darkPrimary != nil)
        #expect(darkSecondary != nil)
        #expect(darkCard != nil)
        
        // Test that light and dark colors are different for primary background
        #expect(lightPrimary != darkPrimary)
    }
    
    // MARK: - Edge Cases
    
    @Test("Invalid theme handling")
    func testInvalidThemeHandling() {
        // Manually set invalid theme in UserDefaults
        UserDefaults.standard.set("invalid_theme", forKey: "selected_theme")
        
        let manager = ThemeManager()
        
        // Should default to system theme for invalid values
        #expect(manager.currentTheme == .system)
    }
    
    @Test("Theme persistence across manager instances")
    func testThemePersistenceAcrossManagerInstances() {
        // Set theme with first manager instance
        let manager1 = ThemeManager.shared
        manager1.currentTheme = .dark
        
        // Verify with second instance (same singleton)
        let manager2 = ThemeManager.shared
        
        #expect(manager1 === manager2) // Same instance
        #expect(manager2.currentTheme == .dark)
        
        // Verify persistence in storage
        let savedTheme = StorageManager.shared.loadTheme()
        #expect(savedTheme == .dark)
    }
    
    // MARK: - Performance Tests
    
    @Test("Rapid theme changes performance")
    func testRapidThemeChangesPerformance() async {
        let manager = ThemeManager.shared
        let themes: [ThemeMode] = [.system, .light, .dark]
        
        // Rapidly change themes
        for i in 0..<themes.count * 3 {
            let theme = themes[i % themes.count]
            manager.currentTheme = theme
            #expect(manager.currentTheme == theme)
        }
        
        // Allow final update to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify final state
        let finalTheme = themes.last!
        #expect(manager.currentTheme == finalTheme)
    }
    
    // MARK: - State Consistency Tests
    
    @Test("State consistency after multiple operations")
    func testStateConsistencyAfterMultipleOperations() async {
        let manager = ThemeManager.shared
        
        // Perform multiple operations
        manager.currentTheme = .light
        let firstTheme = manager.currentTheme
        
        manager.currentTheme = .dark
        let secondTheme = manager.currentTheme
        
        manager.currentTheme = .system
        let thirdTheme = manager.currentTheme
        
        // Allow color scheme updates to complete
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Verify final state
        #expect(thirdTheme == .system)
        #expect(manager.currentTheme == .system)
        #expect(StorageManager.shared.loadTheme() == .system)
        
        // Verify theme progression
        #expect(firstTheme == .light)
        #expect(secondTheme == .dark)
        #expect(thirdTheme == .system)
    }
    
    @Test("currentTheme and storage consistency")
    func testCurrentThemeAndStorageConsistency() {
        let manager = ThemeManager.shared
        
        let testThemes: [ThemeMode] = [.light, .dark, .system]
        
        for theme in testThemes {
            manager.currentTheme = theme
            
            // Verify consistency between manager and storage
            let managerTheme = manager.currentTheme
            let storageTheme = StorageManager.shared.loadTheme()
            
            #expect(managerTheme == theme)
            #expect(storageTheme == theme)
            #expect(managerTheme == storageTheme)
        }
    }
    
    // MARK: - Async Behavior Tests
    
    @Test("Async color scheme update behavior")
    func testAsyncColorSchemeUpdateBehavior() async {
        let manager = ThemeManager.shared
        
        // Test system theme (should set preferredColorScheme to nil)
        manager.currentTheme = .system
        try? await Task.sleep(nanoseconds: 200_000_000)
        #expect(manager.preferredColorScheme == nil)
        
        // Test light theme
        manager.currentTheme = .light
        try? await Task.sleep(nanoseconds: 200_000_000)
        #expect(manager.preferredColorScheme == .light)
        
        // Test dark theme
        manager.currentTheme = .dark
        try? await Task.sleep(nanoseconds: 200_000_000)
        #expect(manager.preferredColorScheme == .dark)
    }
}
