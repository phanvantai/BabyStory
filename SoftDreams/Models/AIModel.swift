import Foundation

// MARK: - AI Provider Enum
enum AIProvider: String, Codable, CaseIterable {
    case openAI = "openai"
    case anthropic = "anthropic"
    case google = "google"
    
    var displayName: String {
        switch self {
        case .openAI:
            return "ai_provider_openai".localized
        case .anthropic:
            return "ai_provider_anthropic".localized
        case .google:
            return "ai_provider_google".localized
        }
    }
}

// MARK: - AI Model Enum
enum AIModel: String, Codable, CaseIterable, Identifiable {
    case gpt35Turbo = "gpt-3.5-turbo"
    case gpt4o = "gpt-4o"
    case claude3Haiku = "claude-3-haiku-20240307"
    case claude3Sonnet = "claude-3-sonnet-20240229"
    case geminiPro = "gemini-pro"
    
    var id: String { rawValue }
    
    // MARK: - Display Properties
    
    /// Localized display name for the model
    var displayName: String {
        switch self {
        case .gpt35Turbo:
            return "ai_model_gpt35_turbo_name".localized
        case .gpt4o:
            return "ai_model_gpt4o_name".localized
        case .claude3Haiku:
            return "ai_model_claude3_haiku_name".localized
        case .claude3Sonnet:
            return "ai_model_claude3_sonnet_name".localized
        case .geminiPro:
            return "ai_model_gemini_pro_name".localized
        }
    }
    
    /// Localized description explaining the model's characteristics
    var description: String {
        switch self {
        case .gpt35Turbo:
            return "ai_model_gpt35_turbo_description".localized
        case .gpt4o:
            return "ai_model_gpt4o_description".localized
        case .claude3Haiku:
            return "ai_model_claude3_haiku_description".localized
        case .claude3Sonnet:
            return "ai_model_claude3_sonnet_description".localized
        case .geminiPro:
            return "ai_model_gemini_pro_description".localized
        }
    }
    
    /// SF Symbols icon for the model
    var icon: String {
        switch self {
        case .gpt35Turbo:
            return "bolt.circle"
        case .gpt4o:
            return "sparkles.circle"
        case .claude3Haiku:
            return "heart.circle"
        case .claude3Sonnet:
            return "heart.circle.fill"
        case .geminiPro:
            return "star.circle"
        }
    }
    
    // MARK: - Model Configuration
    
    /// Whether this model requires a premium subscription
    var isPremium: Bool {
        switch self {
        case .gpt35Turbo:
            return false // Free model
        case .gpt4o, .claude3Haiku, .claude3Sonnet, .geminiPro:
            return true // Premium models
        }
    }
    
    /// The AI provider for this model
    var provider: AIProvider {
        switch self {
        case .gpt35Turbo, .gpt4o:
            return .openAI
        case .claude3Haiku, .claude3Sonnet:
            return .anthropic
        case .geminiPro:
            return .google
        }
    }
    
    /// Maximum tokens for story generation
    var maxTokens: Int {
        switch self {
        case .gpt35Turbo:
            return 1500 // Conservative for free tier
        case .gpt4o:
            return 2000 // More generous for premium
        case .claude3Haiku:
            return 1500 // Fast and efficient
        case .claude3Sonnet:
            return 2000 // Balanced quality and length
        case .geminiPro:
            return 1800 // Good balance
        }
    }
    
    /// Temperature setting for creative writing (0.0 to 1.0)
    var temperature: Double {
        switch self {
        case .gpt35Turbo:
            return 0.8 // Good creativity for basic stories
        case .gpt4o:
            return 0.85 // Higher creativity for premium experience
        case .claude3Haiku:
            return 0.75 // Gentle and consistent
        case .claude3Sonnet:
            return 0.8 // Warm and creative
        case .geminiPro:
            return 0.85 // Creative and varied
        }
    }
    
    // MARK: - Convenience Properties
    
    /// All available free models
    static var freeModels: [AIModel] {
        return allCases.filter { !$0.isPremium }
    }
    
    /// All available premium models
    static var premiumModels: [AIModel] {
        return allCases.filter { $0.isPremium }
    }
    
    /// Default model (free tier)
    static var `default`: AIModel {
        return .gpt35Turbo
    }
    
    // MARK: - Model Selection Helpers
    
    /// Returns models available for a given subscription status
    /// - Parameter isPremiumUser: Whether the user has premium subscription
    /// - Returns: Array of available models
    static func availableModels(for isPremiumUser: Bool) -> [AIModel] {
        if isPremiumUser {
            return allCases // All models available for premium users
        } else {
            return freeModels // Only free models for free users
        }
    }
    
    /// Returns whether a model is available for a given subscription status
    /// - Parameter isPremiumUser: Whether the user has premium subscription
    /// - Returns: True if the model is available for this user
    func isAvailable(for isPremiumUser: Bool) -> Bool {
        if isPremiumUser {
            return true // All models available for premium users
        } else {
            return !isPremium // Only free models for free users
        }
    }
}

// MARK: - Extensions

extension AIModel: Equatable {
    static func == (lhs: AIModel, rhs: AIModel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension AIModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}