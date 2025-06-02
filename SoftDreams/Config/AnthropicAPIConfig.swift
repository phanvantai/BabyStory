//
//  AnthropicAPIConfig.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 2/6/25.
//

import Foundation

enum AnthropicAPIConfig {
    static var apiKey: String? {
        // First try to get a dedicated Claude API key
        if let claudeApiKey = Bundle.main.infoDictionary?["CLAUDE_API_KEY"] as? String,
           !claudeApiKey.isEmpty {
            return claudeApiKey
        }
        
        // Fallback to the main API key if it has a Claude prefix
        if let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String,
           !apiKey.isEmpty,
           apiKey.hasPrefix("claude-") {
            return apiKey
        }
        
        return nil
    }

    static let baseURL = Bundle.main.infoDictionary?["ANTHROPIC_BASE_URL"] as? String ?? "https://api.anthropic.com/v1"
}
