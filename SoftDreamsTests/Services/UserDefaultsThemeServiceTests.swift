import Testing
import Foundation
@testable import SoftDreams

struct UserDefaultsThemeServiceTests {
    
    init() {
        // Clean up before each test
        UserDefaults.standard.removeObject(forKey: "selected_theme")
        UserDefaults.standard.removeObject(forKey: "theme_settings")
        // Clean up theme settings for all modes
        for theme in ThemeMode.allCases {
            UserDefaults.standard.removeObject(forKey: "theme_settings_\(theme.rawValue)")
        }
    }
    
    deinit {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "selected_theme")
        UserDefaults.standard.removeObject(forKey: "theme_settings")
        for theme in ThemeMode.allCases {
            UserDefaults.standard.removeObject(forKey: "theme_settings_\(theme.rawValue)")
        }
    }
    
    @Test("Save and load theme successfully")
    func testSaveAndLoadTheme() {
        let service = UserDefaultsThemeService()
        
        // Test saving light theme
        service.saveTheme(.light)
        #expect(service.loadTheme() == .light)
        
        // Test saving dark theme
        service.saveTheme(.dark)
        #expect(service.loadTheme() == .dark)
        
        // Test saving system theme
        service.saveTheme(.system)
        #expect(service.loadTheme() == .system)
    }
    
    @Test("Load theme when none exists returns default")
    func testLoadThemeWhenNoneExists() {
        let service = UserDefaultsThemeService()
        
        // Should return system as default
        #expect(service.loadTheme() == .system)
    }
    
    @Test("Has custom theme detection")
    func testHasCustomTheme() {
        let service = UserDefaultsThemeService()
        
        // Initially no custom theme
        #expect(service.hasCustomTheme() == false)
        
        // After saving a theme
        service.saveTheme(.light)
        #expect(service.hasCustomTheme() == true)
        
        // After saving system theme (still custom)
        service.saveTheme(.system)
        #expect(service.hasCustomTheme() == true)
    }
    
    @Test("Reset theme clears all theme data")
    func testResetTheme() {
        let service = UserDefaultsThemeService()
        
        // Set up some theme data
        service.saveTheme(.dark)
        service.saveThemeSettings(["setting1": "value1"], for: .dark)
        
        #expect(service.hasCustomTheme() == true)
        #expect(service.loadTheme() == .dark)
        
        // Reset theme
        service.resetTheme()
        
        #expect(service.hasCustomTheme() == false)
        #expect(service.loadTheme() == .system) // Should return default
    }
    
    @Test("Save and load theme settings for different themes")
    func testSaveAndLoadThemeSettings() {
        let service = UserDefaultsThemeService()
        
        let lightSettings: [String: Any] = [
            "brightness": 0.8,
            "contrast": 1.2,
            "useCustomColors": true,
            "accentColor": "blue"
        ]
        
        let darkSettings: [String: Any] = [
            "brightness": 0.3,
            "contrast": 1.5,
            "useCustomColors": false,
            "accentColor": "purple"
        ]
        
        // Save settings for different themes
        service.saveThemeSettings(lightSettings, for: .light)
        service.saveThemeSettings(darkSettings, for: .dark)
        
        // Load and verify light settings
        let loadedLightSettings = service.loadThemeSettings(for: .light)
        #expect(loadedLightSettings["brightness"] as? Double == 0.8)
        #expect(loadedLightSettings["contrast"] as? Double == 1.2)
        #expect(loadedLightSettings["useCustomColors"] as? Bool == true)
        #expect(loadedLightSettings["accentColor"] as? String == "blue")
        
        // Load and verify dark settings
        let loadedDarkSettings = service.loadThemeSettings(for: .dark)
        #expect(loadedDarkSettings["brightness"] as? Double == 0.3)
        #expect(loadedDarkSettings["contrast"] as? Double == 1.5)
        #expect(loadedDarkSettings["useCustomColors"] as? Bool == false)
        #expect(loadedDarkSettings["accentColor"] as? String == "purple")
        
        // System theme should have no settings
        let systemSettings = service.loadThemeSettings(for: .system)
        #expect(systemSettings.isEmpty)
    }
    
    @Test("Load theme settings when none exist")
    func testLoadThemeSettingsWhenNoneExist() {
        let service = UserDefaultsThemeService()
        
        let settings = service.loadThemeSettings(for: .light)
        
        #expect(settings.isEmpty)
    }
    
    @Test("Theme settings support various data types")
    func testThemeSettingsDataTypes() {
        let service = UserDefaultsThemeService()
        
        let complexSettings: [String: Any] = [
            "stringValue": "test string",
            "intValue": 42,
            "doubleValue": 3.14159,
            "boolValue": true,
            "negativeInt": -100,
            "zeroValue": 0
        ]
        
        service.saveThemeSettings(complexSettings, for: .light)
        let loadedSettings = service.loadThemeSettings(for: .light)
        
        #expect(loadedSettings["stringValue"] as? String == "test string")
        #expect(loadedSettings["intValue"] as? Int == 42)
        #expect(loadedSettings["doubleValue"] as? Double == 3.14159)
        #expect(loadedSettings["boolValue"] as? Bool == true)
        #expect(loadedSettings["negativeInt"] as? Int == -100)
        #expect(loadedSettings["zeroValue"] as? Int == 0)
    }
    
    @Test("Theme settings isolation between themes")
    func testThemeSettingsIsolation() {
        let service = UserDefaultsThemeService()
        
        let lightSettings = ["setting": "light_value"]
        let darkSettings = ["setting": "dark_value"]
        let systemSettings = ["setting": "system_value"]
        
        service.saveThemeSettings(lightSettings, for: .light)
        service.saveThemeSettings(darkSettings, for: .dark)
        service.saveThemeSettings(systemSettings, for: .system)
        
        // Verify each theme has its own settings
        #expect(service.loadThemeSettings(for: .light)["setting"] as? String == "light_value")
        #expect(service.loadThemeSettings(for: .dark)["setting"] as? String == "dark_value")
        #expect(service.loadThemeSettings(for: .system)["setting"] as? String == "system_value")
    }
    
    @Test("Update theme settings overwrites existing")
    func testUpdateThemeSettings() {
        let service = UserDefaultsThemeService()
        
        let originalSettings = [
            "setting1": "original1",
            "setting2": "original2"
        ]
        
        service.saveThemeSettings(originalSettings, for: .light)
        
        let updatedSettings = [
            "setting1": "updated1",
            "setting3": "new3"
        ]
        
        service.saveThemeSettings(updatedSettings, for: .light)
        let loadedSettings = service.loadThemeSettings(for: .light)
        
        // Should completely replace, not merge
        #expect(loadedSettings["setting1"] as? String == "updated1")
        #expect(loadedSettings["setting2"] == nil) // Should be removed
        #expect(loadedSettings["setting3"] as? String == "new3")
        #expect(loadedSettings.count == 2)
    }
    
    @Test("Theme mode enum properties")
    func testThemeModeProperties() {
        // Test all theme modes have display names
        for theme in ThemeMode.allCases {
            #expect(theme.displayName.isEmpty == false)
            #expect(theme.icon.isEmpty == false)
        }
        
        // Test specific values
        #expect(ThemeMode.system.rawValue == "system")
        #expect(ThemeMode.light.rawValue == "light")
        #expect(ThemeMode.dark.rawValue == "dark")
        
        // Test icons are reasonable
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
    
    @Test("Theme persistence across service instances")
    func testThemePersistenceAcrossInstances() {
        let service1 = UserDefaultsThemeService()
        service1.saveTheme(.dark)
        
        let service2 = UserDefaultsThemeService()
        #expect(service2.loadTheme() == .dark)
        #expect(service2.hasCustomTheme() == true)
    }
    
    @Test("Empty theme settings handling")
    func testEmptyThemeSettingsHandling() {
        let service = UserDefaultsThemeService()
        
        // Save empty settings
        service.saveThemeSettings([:], for: .light)
        let loadedSettings = service.loadThemeSettings(for: .light)
        
        #expect(loadedSettings.isEmpty)
    }
    
    @Test("Theme settings with special characters")
    func testThemeSettingsWithSpecialCharacters() {
        let service = UserDefaultsThemeService()
        
        let specialSettings: [String: Any] = [
            "unicode_key_🌟": "unicode_value_🦄",
            "key with spaces": "value with spaces",
            "key.with.dots": "value.with.dots",
            "key_with_underscores": "value_with_underscores",
            "key-with-dashes": "value-with-dashes"
        ]
        
        service.saveThemeSettings(specialSettings, for: .system)
        let loadedSettings = service.loadThemeSettings(for: .system)
        
        #expect(loadedSettings["unicode_key_🌟"] as? String == "unicode_value_🦄")
        #expect(loadedSettings["key with spaces"] as? String == "value with spaces")
        #expect(loadedSettings["key.with.dots"] as? String == "value.with.dots")
        #expect(loadedSettings["key_with_underscores"] as? String == "value_with_underscores")
        #expect(loadedSettings["key-with-dashes"] as? String == "value-with-dashes")
    }
    
    @Test("Multiple theme operations sequence")
    func testMultipleThemeOperationsSequence() {
        let service = UserDefaultsThemeService()
        
        // Start with default
        #expect(service.loadTheme() == .system)
        #expect(service.hasCustomTheme() == false)
        
        // Set light theme
        service.saveTheme(.light)
        #expect(service.loadTheme() == .light)
        #expect(service.hasCustomTheme() == true)
        
        // Add settings for light theme
        service.saveThemeSettings(["brightness": 0.9], for: .light)
        #expect(service.loadThemeSettings(for: .light)["brightness"] as? Double == 0.9)
        
        // Switch to dark theme
        service.saveTheme(.dark)
        #expect(service.loadTheme() == .dark)
        #expect(service.hasCustomTheme() == true)
        
        // Light theme settings should still exist
        #expect(service.loadThemeSettings(for: .light)["brightness"] as? Double == 0.9)
        
        // Add settings for dark theme
        service.saveThemeSettings(["brightness": 0.2], for: .dark)
        #expect(service.loadThemeSettings(for: .dark)["brightness"] as? Double == 0.2)
        
        // Reset everything
        service.resetTheme()
        #expect(service.loadTheme() == .system)
        #expect(service.hasCustomTheme() == false)
        #expect(service.loadThemeSettings(for: .light).isEmpty)
        #expect(service.loadThemeSettings(for: .dark).isEmpty)
    }
}
