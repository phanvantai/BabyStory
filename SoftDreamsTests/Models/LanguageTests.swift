//
//  LanguageTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct LanguageTests {
    
    // MARK: - Language Model Tests
    
    @Test("Test Language initialization")
    func testLanguageInitialization() async throws {
        // Given
        let code = "en"
        let name = "English"
        let nativeName = "English"
        let flag = "🇺🇸"
        
        // When
        let language = Language(code: code, name: name, nativeName: nativeName, flag: flag)
        
        // Then
        #expect(language.code == code)
        #expect(language.name == name)
        #expect(language.nativeName == nativeName)
        #expect(language.flag == flag)
    }
    
    @Test("Test Language static definitions")
    func testLanguageStaticDefinitions() async throws {
        // English
        #expect(Language.english.code == "en")
        #expect(Language.english.name == "English")
        #expect(Language.english.nativeName == "English")
        #expect(Language.english.flag == "🇺🇸")
        
        // Vietnamese
        #expect(Language.vietnamese.code == "vi")
        #expect(Language.vietnamese.name == "Vietnamese")
        #expect(Language.vietnamese.nativeName == "Tiếng Việt")
        #expect(Language.vietnamese.flag == "🇻🇳")
    }
    
    @Test("Test Language allCases")
    func testLanguageAllCases() async throws {
        let allCases = Language.allCases
        #expect(allCases.count == 2) // Currently only English and Vietnamese
        #expect(allCases.contains(Language.english))
        #expect(allCases.contains(Language.vietnamese))
    }
    
    @Test("Test Language displayName")
    func testLanguageDisplayName() async throws {
        #expect(Language.english.displayName == "🇺🇸 English")
        #expect(Language.vietnamese.displayName == "🇻🇳 Tiếng Việt")
    }
    
    @Test("Test Language fullDisplayName")
    func testLanguageFullDisplayName() async throws {
        #expect(Language.english.fullDisplayName == "🇺🇸 English (English)")
        #expect(Language.vietnamese.fullDisplayName == "🇻🇳 Tiếng Việt (Vietnamese)")
    }
    
    @Test("Test Language deviceDefault")
    func testLanguageDeviceDefault() async throws {
        // When
        let deviceDefault = Language.deviceDefault
        
        // Then
        #expect(Language.allCases.contains(deviceDefault))
        // Should default to English if current locale is not supported
        #expect(deviceDefault.code == "en" || deviceDefault.code == "vi")
    }
    
    @Test("Test Language preferred property")
    func testLanguagePreferred() async throws {
        // When
        let preferred = Language.preferred
        
        // Then
        #expect(Language.allCases.contains(preferred))
    }
    
    @Test("Test Language codable")
    func testLanguageCodeable() async throws {
        // Given
        let originalLanguage = Language.english
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalLanguage)
        
        let decoder = JSONDecoder()
        let decodedLanguage = try decoder.decode(Language.self, from: data)
        
        // Then
        #expect(decodedLanguage.code == originalLanguage.code)
        #expect(decodedLanguage.name == originalLanguage.name)
        #expect(decodedLanguage.nativeName == originalLanguage.nativeName)
        #expect(decodedLanguage.flag == originalLanguage.flag)
    }
    
    @Test("Test Language hashable")
    func testLanguageHashable() async throws {
        // Given
        let language1 = Language.english
        let language2 = Language.english
        let language3 = Language.vietnamese
        
        // When
        let set = Set([language1, language2, language3])
        
        // Then
        #expect(set.count == 2) // Should only contain unique languages
        #expect(set.contains(language1))
        #expect(set.contains(language3))
    }
    
    @Test("Test Language equality")
    func testLanguageEquality() async throws {
        // Given
        let language1 = Language.english
        let language2 = Language.english
        let language3 = Language.vietnamese
        
        // When & Then
        #expect(language1 == language2)
        #expect(language1 != language3)
    }
}
