import Foundation

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
  var language: Language // Preferred language for stories and UI
  
  // Computed property to determine if this is for an unborn baby
  var isPregnancy: Bool {
    return babyStage == .pregnancy
  }
  
  // Computed property for current age in months based on date of birth
  var currentAge: Int? {
    guard let dateOfBirth = dateOfBirth else { return nil }
    
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
    
    if let years = ageComponents.year, let months = ageComponents.month {
      // Always return age in months for consistency
      return years * 12 + months
    }
    
    return nil // Return nil if calculation fails
  }
  
  // Computed property for current age in years (for display purposes)
  var currentAgeInYears: Int? {
    guard let dateOfBirth = dateOfBirth else { return nil }
    
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
    
    return ageComponents.year
  }
  
  // Computed property for age display string
  var ageDisplayString: String? {
    guard let ageInMonths = currentAge else { return nil }
    
    if ageInMonths < 12 {
      return "\(ageInMonths) month\(ageInMonths == 1 ? "" : "s")"
    } else {
      let years = ageInMonths / 12
      let months = ageInMonths % 12
      
      if months == 0 {
        return "\(years) year\(years == 1 ? "" : "s")"
      } else {
        return "\(years) year\(years == 1 ? "" : "s") \(months) month\(months == 1 ? "" : "s")"
      }
    }
  }
  
  // Computed property for automatically determined baby stage based on date of birth
  var currentBabyStage: BabyStage {
    // Handle pregnancy profiles - if due date has passed, should be newborn
    if babyStage == .pregnancy, let dueDate = dueDate, Date() >= dueDate {
      return .newborn
    }
    
    // For non-pregnancy profiles, calculate stage based on date of birth
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
    gender: Gender = .notSpecified,
    language: Language = Language.deviceDefault
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
    self.language = language
  }
  
  // Method to check if the baby has grown to a new stage
  func hasGrownToNewStage() -> Bool {
    // For pregnancy profiles, check if due date has passed (indicating transition to newborn)
    if babyStage == .pregnancy, let dueDate = dueDate {
      return Date() >= dueDate
    }
    
    // For born babies, check if calculated stage differs from stored stage
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
  
  // MARK: - Auto-Update Helper Methods
  
  /// Checks if the profile should be automatically updated
  var shouldAutoUpdate: Bool {
    return hasGrownToNewStage() || needsUpdate
  }
  
  /// Returns age-appropriate interests for the current baby stage
  func getAgeAppropriateInterests() -> [String] {
    let currentStage = dateOfBirth != nil ? currentBabyStage : babyStage
    return currentStage.availableInterests
  }
  
  /// Filters current interests to keep only age-appropriate ones
  func getFilteredInterests() -> [String] {
    let ageAppropriate = getAgeAppropriateInterests()
    return interests.filter { ageAppropriate.contains($0) }
  }
  
  /// Creates an auto-updated version of this profile
  func createAutoUpdatedProfile() -> UserProfile {
    var updated = self
    
    // Update stage if needed
    if hasGrownToNewStage() {
      updated.babyStage = currentBabyStage
    }
    
    // Update interests to be age-appropriate
    let filteredInterests = getFilteredInterests()
    let ageAppropriate = getAgeAppropriateInterests()
    
    // Keep filtered interests and add suggestions if needed
    var newInterests = filteredInterests
    var suggestions = ageAppropriate.filter { !newInterests.contains($0) }
    
    // Add up to 3 suggested interests if we have fewer than 3
    while newInterests.count < 3 && !suggestions.isEmpty {
      if let suggestion = suggestions.first {
        newInterests.append(suggestion)
        suggestions.removeFirst()
      } else {
        break
      }
    }
    
    updated.interests = newInterests
    updated.lastUpdate = Date()
    
    return updated
  }
}

// MARK: - Validation
extension UserProfile {
  /// Validates the user profile and returns any validation errors
  func validate() -> [AppError] {
    var errors: [AppError] = []
    
    // Name validation
    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      errors.append(.invalidProfile)
    }
    
    // Date validation for pregnancy
    if babyStage == .pregnancy {
      if let dueDate = dueDate {
        // Due date should be in the future or recent past (within 1 month)
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        if dueDate < oneMonthAgo {
          errors.append(.invalidProfile)
        }
      }
      
      // Parent names should be provided for pregnancy
      if parentNames.isEmpty {
        errors.append(.invalidProfile)
      }
    } else {
      // Non-pregnancy profiles should have date of birth
      if dateOfBirth == nil {
        errors.append(.invalidProfile)
      } else if let dateOfBirth = dateOfBirth {
        // Date of birth should not be in the future
        if dateOfBirth > Date() {
          errors.append(.invalidProfile)
        }
        
        // Date of birth should be reasonable (not more than 10 years ago for this app)
        let tenYearsAgo = Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date()
        if dateOfBirth < tenYearsAgo {
          errors.append(.invalidProfile)
        }
      }
    }
    
    // Story time validation (should be within 24 hours)
    let components = Calendar.current.dateComponents([.hour, .minute], from: storyTime)
    if let hour = components.hour, let minute = components.minute {
      if hour < 0 || hour > 23 || minute < 0 || minute > 59 {
        errors.append(.invalidProfile)
      }
    }
    
    return errors
  }
  
  /// Returns true if the profile is valid
  var isValid: Bool {
    return validate().isEmpty
  }
  
  /// Returns a user-friendly validation message
  var validationMessage: String? {
    let errors = validate()
    guard !errors.isEmpty else { return nil }
    
    // Return the first error's description
    return errors.first?.errorDescription
  }
}
