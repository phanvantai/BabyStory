import Foundation

enum StoryLength: String, Codable, CaseIterable, Identifiable {
  case short = "short"
  case medium = "medium" 
  case long = "long"
  
  var id: String { rawValue }
  
  var description: String {
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
      return "Exciting journeys and discoveries"
    case .friendship:
      return "Stories about making friends and caring"
    case .magic:
      return "Enchanted worlds and wonder"
    case .animals:
      return "Friendly creatures and nature"
    case .learning:
      return "Fun lessons and new skills"
    case .kindness:
      return "Being helpful and caring for others"
    case .nature:
      return "Beautiful outdoors and gardens"
    case .family:
      return "Love, togetherness and belonging"
    case .dreams:
      return "Peaceful nighttime adventures"
    case .creativity:
      return "Art, music and imagination"
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
}
