import Foundation

enum Gender: String, Codable, CaseIterable {
  case male = "male"
  case female = "female"
  case other = "other"
  case notSpecified = "not_specified"
  
  var displayName: String {
    switch self {
    case .male:
      return "Boy"
    case .female:
      return "Girl"
    case .other:
      return "Other"
    case .notSpecified:
      return "Not Specified"
    }
  }
  
  var pronoun: String {
    switch self {
    case .male:
      return "he"
    case .female:
      return "she"
    case .other, .notSpecified:
      return "they"
    }
  }
  
  var possessivePronoun: String {
    switch self {
    case .male:
      return "his"
    case .female:
      return "her"
    case .other, .notSpecified:
      return "their"
    }
  }
}

enum BabyStage: String, Codable, CaseIterable {
  case pregnancy = "pregnancy"
  case newborn = "newborn"
  case infant = "infant"
  case toddler = "toddler"
  case preschooler = "preschooler"
  
  var displayName: String {
    switch self {
    case .pregnancy:
      return "During Pregnancy"
    case .newborn:
      return "Newborn (0-3 months)"
    case .infant:
      return "Infant (3-12 months)"
    case .toddler:
      return "Toddler (1-3 years)"
    case .preschooler:
      return "Preschooler (3-5 years)"
    }
  }
  
  var description: String {
    switch self {
    case .pregnancy:
      return "Create bonding stories for your unborn baby"
    case .newborn:
      return "Gentle, soothing stories for newborns"
    case .infant:
      return "Simple stories with sounds and textures"
    case .toddler:
      return "Interactive stories with basic lessons"
    case .preschooler:
      return "Adventure stories with moral lessons"
    }
  }
}

struct UserProfile: Codable, Equatable {
  var name: String
  var babyStage: BabyStage
  var interests: [String]
  var storyTime: Date
  var dueDate: Date? // For pregnancy stage
  var parentNames: [String] // For pregnancy stories
  var dateOfBirth: Date? // For automatic age calculation and stage updates
  var lastUpdate: Date // For tracking when profile was last manually updated
  var gender: Gender // Child's gender for personalized stories
  
  // Computed property to determine if this is for an unborn baby
  var isPregnancy: Bool {
    return babyStage == .pregnancy
  }
  
  // Computed property for current age based on date of birth
  var currentAge: Int? {
    guard let dateOfBirth = dateOfBirth else { return nil }
    
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
    
    if let years = ageComponents.year, let months = ageComponents.month {
      // Return age in months for children under 2, years for older children
      if years < 2 {
        return years * 12 + months
      } else {
        return years
      }
    }
    
    return nil // Return nil if calculation fails
  }
  
  // Computed property for automatically determined baby stage based on date of birth
  var currentBabyStage: BabyStage {
    guard let dateOfBirth = dateOfBirth else { return babyStage }
    
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
    
    guard let years = ageComponents.year, let months = ageComponents.month else {
      return babyStage
    }
    
    let totalMonths = years * 12 + months
    
    switch totalMonths {
    case 0...3:
      return .newborn
    case 4...12:
      return .infant
    case 13...36:
      return .toddler
    case 37...60:
      return .preschooler
    default:
      return .preschooler // Default for children over 5
    }
  }
  
  // Computed property to check if profile needs updating (30 days since last update)
  var needsUpdate: Bool {
    let daysSinceUpdate = Calendar.current.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
    return daysSinceUpdate >= 30
  }
  
  // Computed property for display name
  var displayName: String {
    if isPregnancy {
      return "Baby \(name)"
    } else {
      return name
    }
  }
  
  // Computed property for story context with gender consideration
  var storyContext: String {
    let genderContext = gender != .notSpecified ? " (\(gender.displayName.lowercased()))" : ""
    
    switch babyStage {
    case .pregnancy:
      let parentNamesString = parentNames.isEmpty ? "Mommy and Daddy" : parentNames.joined(separator: " and ")
      return "A story for baby \(name)\(genderContext) from \(parentNamesString)"
    case .newborn, .infant:
      return "A gentle story for little \(name)\(genderContext)"
    case .toddler, .preschooler:
      return "An adventure story for \(name)\(genderContext)"
    }
  }
  
  // Initialize with default values
  init(
    name: String, 
    babyStage: BabyStage = .toddler, 
    interests: [String] = [], 
    storyTime: Date = Date(), 
    dueDate: Date? = nil, 
    parentNames: [String] = [],
    dateOfBirth: Date? = nil,
    lastUpdate: Date = Date(),
    gender: Gender = .notSpecified
  ) {
    self.name = name
    self.babyStage = babyStage
    self.interests = interests
    self.storyTime = storyTime
    self.dueDate = dueDate
    self.parentNames = parentNames
    self.dateOfBirth = dateOfBirth
    self.lastUpdate = lastUpdate
    self.gender = gender
  }
  
  // Method to update profile with current data
  mutating func updateProfile() {
    // Update baby stage based on date of birth if available
    if dateOfBirth != nil {
      self.babyStage = currentBabyStage
    }
    
    // Update last update timestamp
    self.lastUpdate = Date()
  }
  
  // Method to check if the baby has grown to a new stage
  func hasGrownToNewStage() -> Bool {
    return dateOfBirth != nil && currentBabyStage != babyStage
  }
}

// MARK: - UserProfile Extensions
extension UserProfile {
  /// Generates a contextual welcome subtitle based on the current time and baby stage
  func getWelcomeSubtitle() -> String {
    let hour = Calendar.current.component(.hour, from: Date())
    let greeting: String
    
    switch hour {
    case 6..<12:
      greeting = "Good morning!"
    case 12..<17:
      greeting = "Good afternoon!"
    case 17..<21:
      greeting = "Good evening!"
    default:
      greeting = "Sweet dreams!"
    }
    
    // Use current baby stage if available, otherwise use stored stage
    let stageToUse = dateOfBirth != nil ? currentBabyStage : babyStage
    
    switch stageToUse {
    case .pregnancy:
      return "\(greeting) Ready for a bonding story?"
    case .newborn, .infant:
      return "\(greeting) Time for a gentle story?"
    case .toddler:
      return "\(greeting) Ready for an adventure?"
    case .preschooler:
      return "\(greeting) What story shall we explore?"
    }
  }
  
  /// Returns a personalized message when the child has grown to a new stage
  func getGrowthMessage() -> String? {
    guard hasGrownToNewStage() else { return nil }
    
    let newStage = currentBabyStage
    let pronoun = gender.pronoun
    
    switch newStage {
    case .newborn:
      return "🎉 Welcome to the world, \(name)! \(pronoun.capitalized) is now a newborn!"
    case .infant:
      return "🌟 \(name) is growing! \(pronoun.capitalized) is now an infant and ready for new adventures!"
    case .toddler:
      return "🚀 Look who's growing up! \(name) is now a toddler and ready for exciting stories!"
    case .preschooler:
      return "📚 \(name) is becoming such a big kid! \(pronoun.capitalized) is now a preschooler!"
    case .pregnancy:
      return nil // This shouldn't happen in normal growth progression
    }
  }
  
  /// Returns the number of days since the last profile update
  var daysSinceLastUpdate: Int {
    Calendar.current.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
  }
}
