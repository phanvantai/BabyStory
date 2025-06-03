//
//  ThemeManagerTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Testing
import SwiftUI
@testable import SoftDreams

// MARK: - Theme Manager Tests
@MainActor
struct ThemeManagerTests {
    
    // MARK: - Test Initialization
    
    @Test("ThemeManager should initialize with theme from service")
    func testThemeManager_WhenInitialized_ShouldLoadThemeFromService() {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .dark
        
        // When
        let themeManager = ThemeManager(themeService: mockService)
        
        // Then
        #expect(themeManager.currentTheme == .dark)
        #expect(mockService.loadThemeCallCount == 1)
    }
    
    @Test("ThemeManager should initialize with system theme when service returns default")
    func testThemeManager_WhenServiceReturnsDefault_ShouldInitializeWithSystemTheme() {
        // Given
        let mockService = MockThemeService()
        // mockService.savedTheme is nil, so loadTheme() returns .system
        
        // When
        let themeManager = ThemeManager(themeService: mockService)
        
        // Then
        #expect(themeManager.currentTheme == .system)
        #expect(mockService.loadThemeCallCount == 1)
    }
    
    @Test("ThemeManager should set preferredColorScheme to nil for system theme")
    func testThemeManager_WhenSystemTheme_ShouldSetPreferredColorSchemeToNil() async {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .system
        let themeManager = ThemeManager(themeService: mockService)
        
        // Wait for async color scheme update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        #expect(themeManager.preferredColorScheme == nil)
    }
    
    @Test("ThemeManager should set preferredColorScheme to light for light theme")
    func testThemeManager_WhenLightTheme_ShouldSetPreferredColorSchemeToLight() async {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .light
        let themeManager = ThemeManager(themeService: mockService)
        
        // Wait for async color scheme update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        #expect(themeManager.preferredColorScheme == .light)
    }
    
    @Test("ThemeManager should set preferredColorScheme to dark for dark theme")
    func testThemeManager_WhenDarkTheme_ShouldSetPreferredColorSchemeToark() async {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .dark
        let themeManager = ThemeManager(themeService: mockService)
        
        // Wait for async color scheme update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        #expect(themeManager.preferredColorScheme == .dark)
    }
    
    // MARK: - Test Theme Changes
    
    @Test("ThemeManager should save theme when currentTheme changes")
    func testThemeManager_WhenCurrentThemeChanges_ShouldSaveToService() {
        // Given
        let mockService = MockThemeService()
        let themeManager = ThemeManager(themeService: mockService)
        mockService.reset() // Reset call counts
        
        // When
        themeManager.currentTheme = .dark
        
        // Then
        #expect(mockService.saveThemeCallCount == 1)
        #expect(mockService.lastSavedTheme == .dark)
    }
    
    @Test("ThemeManager should not save theme when set to same value")
    func testThemeManager_WhenSameThemeSet_ShouldNotSaveToService() {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .light
        let themeManager = ThemeManager(themeService: mockService)
        mockService.reset() // Reset call counts
        
        // When
        themeManager.currentTheme = .light // Same as current
        
        // Then
        #expect(mockService.saveThemeCallCount == 0)
    }
    
    @Test("ThemeManager should update color scheme when theme changes")
    func testThemeManager_WhenThemeChanges_ShouldUpdateColorScheme() async {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .system
        let themeManager = ThemeManager(themeService: mockService)
        
        // When
        themeManager.currentTheme = .dark
        
        // Wait for async color scheme update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        #expect(themeManager.preferredColorScheme == .dark)
    }
    
    // MARK: - Test Service Failure Scenarios
    
    @Test("ThemeManager should handle service load failure gracefully")
    func testThemeManager_WhenServiceLoadFails_ShouldUseSystemTheme() {
        // Given
        let mockService = MockThemeService()
        mockService.shouldFailLoad = true
        
        // When
        let themeManager = ThemeManager(themeService: mockService)
        
        // Then
        #expect(themeManager.currentTheme == .system)
    }
    
    @Test("ThemeManager should continue working when service save fails")
    func testThemeManager_WhenServiceSaveFails_ShouldContinueWorking() {
        // Given
        let mockService = MockThemeService()
        let themeManager = ThemeManager(themeService: mockService)
        mockService.shouldFailSave = true
        mockService.reset()
        
        // When
        themeManager.currentTheme = .dark
        
        // Then
        #expect(themeManager.currentTheme == .dark) // Theme should still change locally
        #expect(mockService.saveThemeCallCount == 1) // Save should still be attempted
    }
    
    // MARK: - Test System Appearance Changes
    
    @Test("ThemeManager should update color scheme on system appearance change when using system theme")
    func testThemeManager_WhenSystemAppearanceChangesAndUsingSystemTheme_ShouldUpdateColorScheme() async {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .system
        let themeManager = ThemeManager(themeService: mockService)
        
        // Wait for initial setup
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // When
        themeManager.handleSystemAppearanceChange() // Simulate system appearance change
        
        // Wait for async update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        #expect(themeManager.preferredColorScheme == nil) // Should remain nil for system theme
    }
    
    @Test("ThemeManager should not update color scheme on system appearance change when using fixed theme")
    func testThemeManager_WhenSystemAppearanceChangesAndUsingFixedTheme_ShouldNotUpdateColorScheme() async {
        // Given
        let mockService = MockThemeService()
        mockService.savedTheme = .dark
        let themeManager = ThemeManager(themeService: mockService)
        
        // Wait for initial setup
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        let initialColorScheme = themeManager.preferredColorScheme
        
        // When
        themeManager.handleSystemAppearanceChange() // Simulate system appearance change
        
        // Wait for potential async update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        #expect(themeManager.preferredColorScheme == initialColorScheme) // Should not change
    }
    
    // MARK: - Test Singleton Pattern Still Works
    
    @Test("ThemeManager shared instance should be accessible")
    func testThemeManager_SharedInstance_ShouldBeAccessible() {
        // When/Then
        let sharedInstance = ThemeManager.shared
        #expect(sharedInstance != nil)
    }
}
