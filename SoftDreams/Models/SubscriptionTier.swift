//
//  SubscriptionTier.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation

enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "free"
    case premium = "premium"
    
    /// Daily story generation limit for this subscription tier
    var dailyStoryLimit: Int {
        switch self {
        case .free:
            return 3
        case .premium:
            return 20
        }
    }
    
    /// Available AI models for this subscription tier
    var availableModels: [AIModel] {
        switch self {
        case .free:
            return [.gpt35Turbo]
        case .premium:
            return [.gpt35Turbo, .gpt4o]
        }
    }
    
    /// Default AI model for this subscription tier
    var defaultModel: AIModel {
        switch self {
        case .free:
            return .gpt35Turbo
        case .premium:
            return .gpt4o
        }
    }
}
