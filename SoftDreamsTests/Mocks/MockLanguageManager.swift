//
//  MockLanguageManager.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van
//

import SwiftUI
@testable import SoftDreams

class MockLanguageManager: ObservableObject, LanguageManagerProtocol {
    @Published var currentLanguage: String = "en"
    var updatedLanguage: String?
    
    func updateLanguage(_ languageCode: String) {
        updatedLanguage = languageCode
        currentLanguage = languageCode
    }
}
