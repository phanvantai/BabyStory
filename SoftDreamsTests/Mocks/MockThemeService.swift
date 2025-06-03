//
//  MockThemeService.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
@testable import SoftDreams

// MARK: - Mock Theme Service for Testing
class MockThemeService: ThemeServiceProtocol {
    var savedTheme: ThemeMode?
    var shouldFailSave = false
    var shouldFailLoad = false
    
    // Track method calls for testing
    var saveThemeCallCount = 0
    var loadThemeCallCount = 0
    var lastSavedTheme: ThemeMode?
    
    func saveTheme(_ theme: ThemeMode) {
        saveThemeCallCount += 1
        lastSavedTheme = theme
        
        if shouldFailSave {
            // In a real scenario, this might throw an error
            // For now, we'll just not save the theme
            return
        }
        
        savedTheme = theme
    }
    
    func loadTheme() -> ThemeMode {
        loadThemeCallCount += 1
        
        if shouldFailLoad {
            // Return default theme on failure
            return .system
        }
        
        return savedTheme ?? .system
    }
    
    // Helper methods for testing
    func reset() {
        savedTheme = nil
        shouldFailSave = false
        shouldFailLoad = false
        saveThemeCallCount = 0
        loadThemeCallCount = 0
        lastSavedTheme = nil
    }
}
