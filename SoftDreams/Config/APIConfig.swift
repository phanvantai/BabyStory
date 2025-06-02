//
//  APIConfig.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 1/6/25.
//

import Foundation

enum APIConfig {
  static var anthropicAPIKey: String {
    guard let key = Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"] as? String,
          !key.isEmpty,
          !key.hasPrefix("$(") else {
      fatalError("Missing Anthropic API Key. Please set ANTHROPIC_API_KEY in your build configuration or environment variables.")
    }
    return key
  }
  
  static var openAIAPIKey: String {
    guard let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String,
          !key.isEmpty,
          !key.hasPrefix("$(") else {
      fatalError("Missing OpenAI API Key. Please set OPENAI_API_KEY in your build configuration or environment variables.")
    }
    return key
  }
  
  static let anthropicBaseUrl = Bundle.main.infoDictionary?["ANTHROPIC_API_BASE_URL"] as? String ?? "https://api.anthropic.com/v1"
  
  static var openAIBaseUrl: String {
    let configuredUrl = Bundle.main.infoDictionary?["OPENAI_API_BASE_URL"] as? String
    let finalUrl = configuredUrl ?? "https://api.openai.com/v1"
    return finalUrl
  }
}
