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
  
  static var anthropicBaseUrl: String {
    let configuredUrl = Bundle.main.infoDictionary?["ANTHROPIC_API_BASE_URL"] as? String
    print("Configured Anthropic Base URL: \(configuredUrl ?? "nil")")
    
    // Clean up the URL by removing any quotes and whitespace
    if let configuredUrl = configuredUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
       !configuredUrl.isEmpty,
       !configuredUrl.hasPrefix("$(") {
      
      print("Using configured Anthropic Base URL: \(configuredUrl)")
      
      // Remove surrounding quotes if present
      let cleanedUrl = configuredUrl.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
      
      // if not starts with http, add https
      if !cleanedUrl.hasPrefix("http") {
        return "https://\(cleanedUrl)"
      }
    }
    
    return "https://api.anthropic.com/v1"

  }
  
  static var openAIBaseUrl: String {
    let configuredUrl = Bundle.main.infoDictionary?["OPENAI_API_BASE_URL"] as? String
    print("Configured OpenAI Base URL: \(configuredUrl ?? "nil")")
    // Clean up the URL by removing any quotes and whitespace
    if let configuredUrl = configuredUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
       !configuredUrl.isEmpty,
       !configuredUrl.hasPrefix("$(") {
      
      print("Using configured OpenAI Base URL: \(configuredUrl)")
      
      // Remove surrounding quotes if present
      let cleanedUrl = configuredUrl.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
      
      // if not starts with http, add https
      if !cleanedUrl.hasPrefix("http") {
        return "https://\(cleanedUrl)"
      }
    }
    
    return "https://api.openai.com/v1"
  }
}
