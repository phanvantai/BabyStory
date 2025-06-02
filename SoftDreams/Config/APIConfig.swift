//
//  APIConfig.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 1/6/25.
//

import Foundation

enum APIConfig {
  static var anthropicAPIKey: String {
    guard let key = Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"] as? String else {
      fatalError("Missing Anthropic API Key")
    }
    return key
  }
  static var openAIAPIKey: String {
    guard let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
      fatalError("Missing API Key")
    }
    return key
  }
  
  static let anthropicBaseUrl = Bundle.main.infoDictionary?["ANTHROPIC_API_BASE_URL"] as? String ?? "https://api.anthropic.com/v1"
  
  static let openAIBaseUrl = Bundle.main.infoDictionary?["OPENAI_API_BASE_URL"] as? String ?? "https://api.openai.com/v1"
}
