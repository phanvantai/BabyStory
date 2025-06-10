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
  case gpt35Turbo16k = "gpt-3.5-turbo-16k"
  case gpt4 = "gpt-4"
  case gpt4Turbo = "gpt-4-turbo"
  case gpt4Mini = "gpt-4o-mini"
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
      case .gpt35Turbo16k:
        return "ai_model_gpt35_turbo_16k_name".localized
      case .gpt4:
        return "ai_model_gpt4_name".localized
      case .gpt4Turbo:
        return "ai_model_gpt4_turbo_name".localized
      case .gpt4Mini:
        return "ai_model_gpt4_mini_name".localized
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
      case .gpt35Turbo16k:
        return "ai_model_gpt35_turbo_16k_description".localized
      case .gpt4:
        return "ai_model_gpt4_description".localized
      case .gpt4Turbo:
        return "ai_model_gpt4_turbo_description".localized
      case .gpt4Mini:
        return "ai_model_gpt4_mini_description".localized
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
      case .gpt35Turbo16k:
        return "bolt.circle.fill"
      case .gpt4:
        return "brain.head.profile"
      case .gpt4Turbo:
        return "bolt.horizontal.circle"
      case .gpt4Mini:
        return "sparkle.magnifyingglass"
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
      case .gpt35Turbo, .gpt4Mini:
        return false // Free models
      case .gpt35Turbo16k, .gpt4, .gpt4Turbo, .gpt4o, .claude3Haiku, .claude3Sonnet, .geminiPro:
        return true // Premium models
    }
  }
  
  /// The AI provider for this model
  var provider: AIProvider {
    switch self {
      case .gpt35Turbo, .gpt35Turbo16k, .gpt4, .gpt4Turbo, .gpt4Mini, .gpt4o:
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
      case .gpt35Turbo16k:
        return 2500 // Longer context allows more tokens
      case .gpt4:
        return 2000 // Premium quality
      case .gpt4Turbo:
        return 2200 // Fast and high quality
      case .gpt4Mini:
        return 1200 // Smaller but efficient
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
        return 0.85 // Good creativity for basic stories
      case .gpt35Turbo16k:
        return 0.85 // Good creativity with longer context
      case .gpt4:
        return 0.8 // Balanced creativity and quality
      case .gpt4Turbo:
        return 0.85 // Creative and fast
      case .gpt4Mini:
        return 0.8 // Balanced for efficiency
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
