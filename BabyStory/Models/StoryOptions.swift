import Foundation

enum StoryLength: String, Codable, CaseIterable, Identifiable {
  case short = "short"
  case medium = "medium" 
  case long = "long"
  
  var id: String { rawValue }
  
  var description: String {
    switch self {
    case .short:
      return "story_length_short".localized
    case .medium:
      return "story_length_medium".localized
    case .long:
      return "story_length_long".localized
    }
  }
  
  /// Detailed description for AI prompts including word count and structure guidance
  var aiPromptDescription: String {
    switch self {
    case .short:
      return "Quick tale (2-3 minutes)"
    case .medium:
      return "Perfect story (5-7 minutes)"
    case .long:
      return "Extended adventure (10+ minutes)"
    }
  }
}

enum StoryTheme: String, Codable, CaseIterable, Identifiable {
  case adventure = "Adventure"
  case friendship = "Friendship" 
  case magic = "Magic"
  case animals = "Animals"
  case learning = "Learning"
  case kindness = "Kindness"
  case nature = "Nature"
  case family = "Family"
  case dreams = "Dreams"
  case creativity = "Creativity"
  
  var id: String { rawValue }
  
  var description: String {
    switch self {
    case .adventure:
      return "story_theme_adventure".localized
    case .friendship:
      return "story_theme_friendship".localized
    case .magic:
      return "story_theme_magic".localized
    case .animals:
      return "story_theme_animals".localized
    case .learning:
      return "story_theme_learning".localized
    case .kindness:
      return "story_theme_kindness".localized
    case .nature:
      return "story_theme_nature".localized
    case .family:
      return "story_theme_family".localized
    case .dreams:
      return "story_theme_dreams".localized
    case .creativity:
      return "story_theme_creativity".localized
    }
  }
  
  var icon: String {
    switch self {
    case .adventure:
      return "map.fill"
    case .friendship:
      return "heart.fill"
    case .magic:
      return "sparkles"
    case .animals:
      return "pawprint.fill"
    case .learning:
      return "book.fill"
    case .kindness:
      return "hands.sparkles.fill"
    case .nature:
      return "leaf.fill"
    case .family:
      return "house.fill"
    case .dreams:
      return "moon.stars.fill"
    case .creativity:
      return "paintbrush.fill"
    }
  }
}

struct StoryOptions: Codable, Equatable {
  var length: StoryLength
  var theme: String
  var characters: [String]
  var customTheme: String?
  
  init(length: StoryLength = .medium, theme: String = "Adventure", characters: [String] = [], customTheme: String? = nil) {
    self.length = length
    self.theme = theme
    self.characters = characters
    self.customTheme = customTheme
  }
  
  var effectiveTheme: String {
    return customTheme?.isEmpty == false ? customTheme! : theme
  }
  
  /// Validates the story options
  func validate() -> [AppError] {
    var errors: [AppError] = []
    
    // Theme validation
    if theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      errors.append(.invalidProfile)
    }
    
    // Custom theme validation
    if let customTheme = customTheme, 
       !customTheme.isEmpty && 
       customTheme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      errors.append(.invalidProfile)
    }
    
    // Characters validation
    let validCharacters = characters.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    if validCharacters.count != characters.count {
      errors.append(.invalidProfile)
    }
    
    // Limit characters to reasonable number
    if characters.count > 5 {
      errors.append(.invalidProfile)
    }
    
    return errors
  }
  
  /// Returns true if the options are valid
  var isValid: Bool {
    return validate().isEmpty
  }
  
  /// Returns a cleaned version of the story options
  func cleaned() -> StoryOptions {
    var cleaned = self
    
    // Clean theme
    cleaned.theme = theme.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Clean custom theme
    if let customTheme = customTheme {
      let trimmed = customTheme.trimmingCharacters(in: .whitespacesAndNewlines)
      cleaned.customTheme = trimmed.isEmpty ? nil : trimmed
    }
    
    // Clean characters
    cleaned.characters = characters
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .prefix(5) // Limit to 5 characters
      .map { String($0) }
    
    return cleaned
  }
}
