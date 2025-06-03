//
//  LanguageManagerProtocol.swift
//  SoftDreams
//
//  Created by Tai Phan Van
//

import Foundation

/// Protocol for language management
protocol LanguageManagerProtocol: ObservableObject {
    /// Current language code
    var currentLanguage: String { get set }
    
    /// Updates the current language and saves to UserDefaults
    /// - Parameter languageCode: The language code to set
    func updateLanguage(_ languageCode: String)
}

// MARK: - LanguageManager Protocol Conformance
extension LanguageManager: LanguageManagerProtocol {
    // Already conforms to the protocol
}
