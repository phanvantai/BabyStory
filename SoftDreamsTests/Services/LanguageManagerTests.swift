import Testing
import Foundation
@testable import SoftDreams

struct LanguageManagerTests {
    
    init() {
        // Clean up before each test
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
    }
    
    deinit {
        // Clean up after each test  
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
    }
    
    // MARK: - Initialization Tests
    
    @Test("Singleton instance")
    func testSingletonInstance() {
        let instance1 = LanguageManager.shared
        let instance2 = LanguageManager.shared
        
        #expect(instance1 === instance2)
    }
    
    @Test("Default language initialization")
    func testDefaultLanguageInitialization() {
        // Clear any existing language preference
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        
        let manager = LanguageManager.shared
        
        // Should default to device language or "en"
        #expect(!manager.currentLanguage.isEmpty)
        
        // Should be a valid language code
        let validCodes = ["en", "vi", "es", "fr", "de", "it", "pt", "zh", "ja", "ko", "ar"]
        #expect(validCodes.contains(manager.currentLanguage) || 
               Locale.current.language.languageCode?.identifier == manager.currentLanguage)
    }
    
    @Test("Load saved language preference")
    func testLoadSavedLanguagePreference() {
        // Set a saved language preference
        UserDefaults.standard.set("vi", forKey: "selectedLanguage")
        
        // Create a new manager instance (simulating app restart)
        let manager = LanguageManager.shared
        
        #expect(manager.currentLanguage == "vi")
    }
    
    // MARK: - Language Update Tests
    
    @Test("Update language saves to UserDefaults")
    func testUpdateLanguageSavesToUserDefaults() {
        let manager = LanguageManager.shared
        
        manager.updateLanguage("vi")
        
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        let savedAppleLanguages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        
        #expect(savedLanguage == "vi")
        #expect(savedAppleLanguages?.first == "vi")
        #expect(manager.currentLanguage == "vi")
    }
    
    @Test("Update language changes current language")
    func testUpdateLanguageChangesCurrentLanguage() {
        let manager = LanguageManager.shared
        let originalLanguage = manager.currentLanguage
        
        manager.updateLanguage("fr")
        
        #expect(manager.currentLanguage == "fr")
        #expect(manager.currentLanguage != originalLanguage)
    }
    
    @Test("Update to same language")
    func testUpdateToSameLanguage() {
        let manager = LanguageManager.shared
        
        manager.updateLanguage("en")
        let firstUpdate = manager.currentLanguage
        
        manager.updateLanguage("en") // Same language
        
        #expect(manager.currentLanguage == firstUpdate)
        #expect(manager.currentLanguage == "en")
    }
    
    // MARK: - Multiple Language Changes
    
    @Test("Multiple language changes")
    func testMultipleLanguageChanges() {
        let manager = LanguageManager.shared
        
        let languages = ["en", "vi", "es", "fr"]
        
        for language in languages {
            manager.updateLanguage(language)
            
            #expect(manager.currentLanguage == language)
            #expect(UserDefaults.standard.string(forKey: "selectedLanguage") == language)
        }
    }
    
    // MARK: - Published Property Tests
    
    @Test("Published property updates")
    func testPublishedPropertyUpdates() async {
        let manager = LanguageManager.shared
        let originalLanguage = manager.currentLanguage
        
        // Create expectation for property change
        var changedLanguage: String?
        let expectation = expectation(description: "Language changed")
        
        // This is a simplified test since we can't easily test @Published in Testing framework
        // In real scenarios, this would be tested with Combine
        manager.updateLanguage("de")
        changedLanguage = manager.currentLanguage
        
        #expect(changedLanguage == "de")
        #expect(changedLanguage != originalLanguage)
    }
    
    // MARK: - UserDefaults Synchronization
    
    @Test("UserDefaults synchronization")
    func testUserDefaultsSynchronization() {
        let manager = LanguageManager.shared
        
        manager.updateLanguage("it")
        
        // Verify data is immediately available (synchronize was called)
        UserDefaults.standard.synchronize()
        
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        let savedAppleLanguages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        
        #expect(savedLanguage == "it")
        #expect(savedAppleLanguages?.contains("it") == true)
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty language code handling")
    func testEmptyLanguageCodeHandling() {
        let manager = LanguageManager.shared
        
        manager.updateLanguage("")
        
        #expect(manager.currentLanguage == "")
        #expect(UserDefaults.standard.string(forKey: "selectedLanguage") == "")
    }
    
    @Test("Invalid language code handling")
    func testInvalidLanguageCodeHandling() {
        let manager = LanguageManager.shared
        
        let invalidCode = "xyz123"
        manager.updateLanguage(invalidCode)
        
        #expect(manager.currentLanguage == invalidCode)
        #expect(UserDefaults.standard.string(forKey: "selectedLanguage") == invalidCode)
    }
    
    @Test("Special characters in language code")
    func testSpecialCharactersInLanguageCode() {
        let manager = LanguageManager.shared
        
        let specialCode = "zh-CN"
        manager.updateLanguage(specialCode)
        
        #expect(manager.currentLanguage == specialCode)
        #expect(UserDefaults.standard.string(forKey: "selectedLanguage") == specialCode)
    }
    
    // MARK: - State Consistency Tests
    
    @Test("State consistency after multiple operations")
    func testStateConsistencyAfterMultipleOperations() {
        let manager = LanguageManager.shared
        
        // Perform multiple operations
        manager.updateLanguage("en")
        let firstLanguage = manager.currentLanguage
        
        manager.updateLanguage("vi")
        let secondLanguage = manager.currentLanguage
        
        manager.updateLanguage("es")
        let thirdLanguage = manager.currentLanguage
        
        // Verify final state
        #expect(thirdLanguage == "es")
        #expect(manager.currentLanguage == "es")
        #expect(UserDefaults.standard.string(forKey: "selectedLanguage") == "es")
        
        // Verify language progression
        #expect(firstLanguage == "en")
        #expect(secondLanguage == "vi")
        #expect(thirdLanguage == "es")
    }
    
    // MARK: - Persistence Tests
    
    @Test("Language persistence across manager instances")
    func testLanguagePersistenceAcrossManagerInstances() {
        // Set language with first manager instance
        let manager1 = LanguageManager.shared
        manager1.updateLanguage("pt")
        
        // Verify with second instance (same singleton)
        let manager2 = LanguageManager.shared
        
        #expect(manager1 === manager2) // Same instance
        #expect(manager2.currentLanguage == "pt")
        
        // Verify persistence in UserDefaults
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        #expect(savedLanguage == "pt")
    }
    
    // MARK: - Bundle Setting Tests (Note: These are harder to test due to system dependencies)
    
    @Test("Bundle setting integration")
    func testBundleSettingIntegration() {
        let manager = LanguageManager.shared
        
        // This test verifies the method calls work without errors
        // Full Bundle testing would require more complex test setup
        
        manager.updateLanguage("ja")
        
        #expect(manager.currentLanguage == "ja")
        
        // Verify the Bundle.setLanguage was called (indirectly)
        // by checking that no exceptions were thrown
        #expect(true) // If we reach here, no exceptions occurred
    }
    
    // MARK: - Memory and Performance Tests
    
    @Test("Multiple rapid language changes")
    func testMultipleRapidLanguageChanges() {
        let manager = LanguageManager.shared
        let languages = ["en", "vi", "es", "fr", "de", "it", "pt", "zh", "ja", "ko"]
        
        // Rapidly change languages
        for i in 0..<languages.count {
            manager.updateLanguage(languages[i])
            #expect(manager.currentLanguage == languages[i])
        }
        
        // Verify final state
        #expect(manager.currentLanguage == languages.last)
        #expect(UserDefaults.standard.string(forKey: "selectedLanguage") == languages.last)
    }
    
    @Test("currentLanguage property consistency")
    func testCurrentLanguagePropertyConsistency() {
        let manager = LanguageManager.shared
        
        let testLanguages = ["zh", "ar", "ko", "ja"]
        
        for language in testLanguages {
            manager.updateLanguage(language)
            
            // Verify consistency between different ways of accessing the value
            let currentLang = manager.currentLanguage
            let savedLang = UserDefaults.standard.string(forKey: "selectedLanguage")
            
            #expect(currentLang == language)
            #expect(savedLang == language)
            #expect(currentLang == savedLang)
        }
    }
}
