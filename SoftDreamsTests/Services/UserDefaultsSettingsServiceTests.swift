import Testing
import Foundation
@testable import SoftDreams

struct UserDefaultsSettingsServiceTests {
    
    init() {
        // Clean up before each test
        cleanupUserDefaults()
    }
    
    private func cleanupUserDefaults() {
        let keys = [
            "test_string_setting",
            "test_int_setting", 
            "test_bool_setting",
            "test_double_setting",
            "test_float_setting",
            "test_complex_setting",
            StorageKeys.narrationEnabled,
            "nonexistent_key"
        ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // MARK: - Basic Save/Load Tests
    
    @Test("Save and load string setting")
    func testSaveAndLoadStringSetting() throws {
        let service = UserDefaultsSettingsService()
        let testValue = "test string value"
        
        try service.saveSetting(testValue, forKey: "test_string_setting")
        let loadedValue = try service.loadSetting(String.self, forKey: "test_string_setting")
        
        #expect(loadedValue == testValue)
    }
    
    @Test("Save and load integer setting")
    func testSaveAndLoadIntegerSetting() throws {
        let service = UserDefaultsSettingsService()
        let testValue = 42
        
        try service.saveSetting(testValue, forKey: "test_int_setting")
        let loadedValue = try service.loadSetting(Int.self, forKey: "test_int_setting")
        
        #expect(loadedValue == testValue)
    }
    
    @Test("Save and load boolean setting")
    func testSaveAndLoadBooleanSetting() throws {
        let service = UserDefaultsSettingsService()
        let testValue = true
        
        try service.saveSetting(testValue, forKey: "test_bool_setting")
        let loadedValue = try service.loadSetting(Bool.self, forKey: "test_bool_setting")
        
        #expect(loadedValue == testValue)
    }
    
    @Test("Save and load double setting")
    func testSaveAndLoadDoubleSetting() throws {
        let service = UserDefaultsSettingsService()
        let testValue = 3.14159
        
        try service.saveSetting(testValue, forKey: "test_double_setting")
        let loadedValue = try service.loadSetting(Double.self, forKey: "test_double_setting")
        
        #expect(loadedValue == testValue)
    }
    
    @Test("Save and load float setting")
    func testSaveAndLoadFloatSetting() throws {
        let service = UserDefaultsSettingsService()
        let testValue: Float = 2.718
        
        try service.saveSetting(testValue, forKey: "test_float_setting")
        let loadedValue = try service.loadSetting(Float.self, forKey: "test_float_setting")
        
        #expect(loadedValue == testValue)
    }
    
    // MARK: - Complex Type Tests
    
    @Test("Save and load complex Codable type")
    func testSaveAndLoadComplexSetting() throws {
        struct TestStruct: Codable, Equatable {
            let name: String
            let value: Int
            let isActive: Bool
        }
        
        let service = UserDefaultsSettingsService()
        let testValue = TestStruct(name: "test", value: 100, isActive: true)
        
        try service.saveSetting(testValue, forKey: "test_complex_setting")
        let loadedValue = try service.loadSetting(TestStruct.self, forKey: "test_complex_setting")
        
        #expect(loadedValue == testValue)
    }
    
    // MARK: - Load Non-Existent Setting Tests
    
    @Test("Load non-existent string setting returns nil")
    func testLoadNonExistentStringSetting() throws {
        let service = UserDefaultsSettingsService()
        
        let loadedValue = try service.loadSetting(String.self, forKey: "nonexistent_key")
        
        #expect(loadedValue == nil)
    }
    
    @Test("Load non-existent complex setting returns nil")
    func testLoadNonExistentComplexSetting() throws {
        struct TestStruct: Codable {
            let name: String
        }
        
        let service = UserDefaultsSettingsService()
        
        let loadedValue = try service.loadSetting(TestStruct.self, forKey: "nonexistent_key")
        
        #expect(loadedValue == nil)
    }
    
    // MARK: - Setting Management Tests
    
    @Test("Remove setting")
    func testRemoveSetting() throws {
        let service = UserDefaultsSettingsService()
        let testValue = "value to remove"
        
        try service.saveSetting(testValue, forKey: "test_string_setting")
        #expect(service.settingExists(forKey: "test_string_setting") == true)
        
        service.removeSetting(forKey: "test_string_setting")
        #expect(service.settingExists(forKey: "test_string_setting") == false)
    }
    
    @Test("Setting exists check")
    func testSettingExists() throws {
        let service = UserDefaultsSettingsService()
        
        #expect(service.settingExists(forKey: "test_string_setting") == false)
        
        try service.saveSetting("test", forKey: "test_string_setting")
        #expect(service.settingExists(forKey: "test_string_setting") == true)
    }
    
    @Test("Get all setting keys")
    func testGetAllSettingKeys() throws {
        let service = UserDefaultsSettingsService()
        
        try service.saveSetting("test1", forKey: "test_string_setting")
        try service.saveSetting(42, forKey: "test_int_setting")
        
        let keys = service.getAllSettingKeys()
        
        #expect(keys.contains("test_string_setting"))
        #expect(keys.contains("test_int_setting"))
    }
    
    @Test("Save multiple settings at once")
    func testSaveMultipleSettings() throws {
        let service = UserDefaultsSettingsService()
        let settings: [String: Any] = [
            "test_string_setting": "test value",
            "test_int_setting": 42,
            "test_bool_setting": true
        ]
        
        try service.saveSettings(settings)
        
        let stringValue = try service.loadSetting(String.self, forKey: "test_string_setting")
        let intValue = try service.loadSetting(Int.self, forKey: "test_int_setting")
        let boolValue = try service.loadSetting(Bool.self, forKey: "test_bool_setting")
        
        #expect(stringValue == "test value")
        #expect(intValue == 42)
        #expect(boolValue == true)
    }
    
    @Test("Remove multiple settings")
    func testRemoveMultipleSettings() throws {
        let service = UserDefaultsSettingsService()
        
        try service.saveSetting("test1", forKey: "test_string_setting")
        try service.saveSetting(42, forKey: "test_int_setting")
        try service.saveSetting(true, forKey: "test_bool_setting")
        
        service.removeSettings(forKeys: ["test_string_setting", "test_int_setting"])
        
        #expect(service.settingExists(forKey: "test_string_setting") == false)
        #expect(service.settingExists(forKey: "test_int_setting") == false)
        #expect(service.settingExists(forKey: "test_bool_setting") == true)
    }
    
    // MARK: - Get All Settings Tests
    
    @Test("Get all settings")
    func testGetAllSettings() throws {
        let service = UserDefaultsSettingsService()
        
        // Set up some app-specific settings
        try service.saveSetting(true, forKey: StorageKeys.narrationEnabled)
        
        let allSettings = try service.getAllSettings()
        
        #expect(allSettings[StorageKeys.narrationEnabled] as? Bool == true)
    }
    
    @Test("Get all settings when empty")
    func testGetAllSettingsWhenEmpty() throws {
        let service = UserDefaultsSettingsService()
        
        let allSettings = try service.getAllSettings()
        
        #expect(allSettings.isEmpty)
    }
    
    // MARK: - Reset Settings Tests
    
    @Test("Reset all settings")
    func testResetAllSettings() throws {
        let service = UserDefaultsSettingsService()
        
        // Set up some settings
        try service.saveSetting(true, forKey: StorageKeys.narrationEnabled)
        
        #expect(service.settingExists(forKey: StorageKeys.narrationEnabled))
        
        try service.resetAllSettings()
        
        #expect(service.settingExists(forKey: StorageKeys.narrationEnabled) == false)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Error handling for corrupted complex data")
    func testErrorHandlingCorruptedComplexData() {
        struct TestStruct: Codable {
            let name: String
        }
        
        let service = UserDefaultsSettingsService()
        
        // Manually set corrupted data
        UserDefaults.standard.set("corrupted data", forKey: "test_complex_setting")
        
        #expect(throws: AppError.self) {
            try service.loadSetting(TestStruct.self, forKey: "test_complex_setting")
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Save and load empty string")
    func testSaveAndLoadEmptyString() throws {
        let service = UserDefaultsSettingsService()
        let testValue = ""
        
        try service.saveSetting(testValue, forKey: "test_string_setting")
        let loadedValue = try service.loadSetting(String.self, forKey: "test_string_setting")
        
        #expect(loadedValue == testValue)
    }
    
    @Test("Save and load zero values")
    func testSaveAndLoadZeroValues() throws {
        let service = UserDefaultsSettingsService()
        
        try service.saveSetting(0, forKey: "test_int_setting")
        try service.saveSetting(0.0, forKey: "test_double_setting")
        try service.saveSetting(false, forKey: "test_bool_setting")
        
        let intValue = try service.loadSetting(Int.self, forKey: "test_int_setting")
        let doubleValue = try service.loadSetting(Double.self, forKey: "test_double_setting")
        let boolValue = try service.loadSetting(Bool.self, forKey: "test_bool_setting")
        
        #expect(intValue == 0)
        #expect(doubleValue == 0.0)
        #expect(boolValue == false)
    }
    
    @Test("Complex type with nested structures")
    func testComplexTypeWithNestedStructures() throws {
        struct Address: Codable, Equatable {
            let street: String
            let city: String
        }
        
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
            let address: Address
            let hobbies: [String]
        }
        
        let service = UserDefaultsSettingsService()
        let testValue = Person(
            name: "John Doe",
            age: 30,
            address: Address(street: "123 Main St", city: "Anytown"),
            hobbies: ["reading", "swimming"]
        )
        
        try service.saveSetting(testValue, forKey: "test_complex_setting")
        let loadedValue = try service.loadSetting(Person.self, forKey: "test_complex_setting")
        
        #expect(loadedValue == testValue)
    }
    
    @Test("Data consistency across operations")
    func testDataConsistencyAcrossOperations() throws {
        let service = UserDefaultsSettingsService()
        
        // Save initial settings
        try service.saveSetting("value1", forKey: "test_string_setting")
        try service.saveSetting(100, forKey: "test_int_setting")
        
        // Verify they exist
        #expect(service.settingExists(forKey: "test_string_setting"))
        #expect(service.settingExists(forKey: "test_int_setting"))
        
        // Update one setting
        try service.saveSetting("updated_value", forKey: "test_string_setting")
        
        // Verify the updated value and unchanged value
        let stringValue = try service.loadSetting(String.self, forKey: "test_string_setting")
        let intValue = try service.loadSetting(Int.self, forKey: "test_int_setting")
        
        #expect(stringValue == "updated_value")
        #expect(intValue == 100)
        
        // Remove one setting
        service.removeSetting(forKey: "test_string_setting")
        
        // Verify removal
        #expect(service.settingExists(forKey: "test_string_setting") == false)
        #expect(service.settingExists(forKey: "test_int_setting"))
    }
}
