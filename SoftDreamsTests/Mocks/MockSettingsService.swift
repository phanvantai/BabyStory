//
//  MockSettingsService.swift
//  SoftDreamsTests
//
//  Created by Tests on 3/6/25.
//

import Foundation
@testable import SoftDreams

class MockSettingsService: SettingsServiceProtocol {
    
    // MARK: - Mock Properties
    var shouldFailSave = false
    var shouldFailLoad = false
    
    // MARK: - Narration Enabled
    var narrationEnabledValue: Bool = true
    var saveNarrationEnabledCalled = false
    var savedNarrationEnabled: Bool?
    
    // MARK: - Generic Storage
    private var storage: [String: Any] = [:]
    
    // MARK: - SettingsServiceProtocol Implementation
    
    func saveSetting<T: Codable>(_ value: T, forKey key: String) throws {
        if shouldFailSave {
            throw AppError.dataSaveFailed
        }
        
        // Handle specific settings for easy testing
        if key == StorageKeys.narrationEnabled, let boolValue = value as? Bool {
            saveNarrationEnabledCalled = true
            savedNarrationEnabled = boolValue
            narrationEnabledValue = boolValue
        }
        
        storage[key] = value
    }
    
    func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        if shouldFailLoad {
            throw AppError.dataCorruption
        }
        
        // Handle specific settings for easy testing
        if key == StorageKeys.narrationEnabled && type == Bool.self {
            return narrationEnabledValue as? T
        }
        
        return storage[key] as? T
    }
    
    func removeSetting(forKey key: String) {
        storage.removeValue(forKey: key)
    }
    
    func getAllSettings() throws -> [String: Any] {
        if shouldFailLoad {
            throw AppError.dataCorruption
        }
        return storage
    }
    
    func settingExists(forKey key: String) -> Bool {
        return storage[key] != nil
    }
    
    func getAllSettingKeys() -> [String] {
        return Array(storage.keys)
    }
    
    func saveSettings(_ settings: [String: Any]) throws {
        if shouldFailSave {
            throw AppError.dataSaveFailed
        }
        for (key, value) in settings {
            storage[key] = value
        }
    }
    
    func removeSettings(forKeys keys: [String]) {
        for key in keys {
            storage.removeValue(forKey: key)
        }
    }
    
    func resetAllSettings() throws {
        if shouldFailSave {
            throw AppError.dataSaveFailed
        }
        storage.removeAll()
    }
}
