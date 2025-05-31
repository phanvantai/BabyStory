//
//  ProfileValidation.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation

// MARK: - Profile Validation Rules
struct ProfileValidationRules {
  static let minNameLength = 1
  static let maxNameLength = 50
  static let maxCharactersInStory = 5
  static let maxInterests = 10
  static let maxParentNames = 2
  static let maxChildAgeYears = 10
  static let storyTimeValidHours = 0...23
  static let storyTimeValidMinutes = 0...59
  
  // Date ranges
  static var maxDueDateFuture: Date {
    Calendar.current.date(byAdding: .month, value: 12, to: Date()) ?? Date()
  }
  
  static var minDueDatePast: Date {
    Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
  }
  
  static var maxChildAge: Date {
    Calendar.current.date(byAdding: .year, value: -maxChildAgeYears, to: Date()) ?? Date()
  }
}

// MARK: - Validation Result
struct ValidationResult {
  let isValid: Bool
  let errors: [AppError]
  let warnings: [String]
  
  init(errors: [AppError] = [], warnings: [String] = []) {
    self.errors = errors
    self.warnings = warnings
    self.isValid = errors.isEmpty
  }
  
  var hasWarnings: Bool {
    return !warnings.isEmpty
  }
  
  var primaryError: AppError? {
    return errors.first
  }
  
  var primaryWarning: String? {
    return warnings.first
  }
}

// MARK: - Profile Validator
class ProfileValidator {
  
  /// Comprehensive validation of a user profile
  static func validate(_ profile: UserProfile) -> ValidationResult {
    var errors: [AppError] = []
    var warnings: [String] = []
    
    // Name validation
    let nameErrors = validateName(profile.name)
    errors.append(contentsOf: nameErrors)
    
    // Stage-specific validation
    switch profile.babyStage {
    case .pregnancy:
      let pregnancyResult = validatePregnancyProfile(profile)
      errors.append(contentsOf: pregnancyResult.errors)
      warnings.append(contentsOf: pregnancyResult.warnings)
      
    default:
      let childResult = validateChildProfile(profile)
      errors.append(contentsOf: childResult.errors)
      warnings.append(contentsOf: childResult.warnings)
    }
    
    // Story time validation
    let storyTimeErrors = validateStoryTime(profile.storyTime)
    errors.append(contentsOf: storyTimeErrors)
    
    // Interests validation
    let interestsWarnings = validateInterests(profile.interests, for: profile.babyStage)
    warnings.append(contentsOf: interestsWarnings)
    
    return ValidationResult(errors: errors, warnings: warnings)
  }
  
  // MARK: - Private Validation Methods
  
  private static func validateName(_ name: String) -> [AppError] {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmedName.isEmpty {
      return [.invalidName]
    }
    
    if trimmedName.count < ProfileValidationRules.minNameLength ||
       trimmedName.count > ProfileValidationRules.maxNameLength {
      return [.invalidName]
    }
    
    return []
  }
  
  private static func validatePregnancyProfile(_ profile: UserProfile) -> ValidationResult {
    var errors: [AppError] = []
    var warnings: [String] = []
    
    // Due date validation
    if let dueDate = profile.dueDate {
      if dueDate < ProfileValidationRules.minDueDatePast {
        errors.append(.invalidDate)
      } else if dueDate > ProfileValidationRules.maxDueDateFuture {
        warnings.append("profile_validation_due_date_far_future".localized)
      }
    } else {
      errors.append(.profileIncomplete)
    }
    
    // Parent names validation
    if profile.parentNames.isEmpty {
      errors.append(.profileIncomplete)
    } else {
      for parentName in profile.parentNames {
        if parentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          errors.append(.invalidName)
          break
        }
      }
      
      if profile.parentNames.count > ProfileValidationRules.maxParentNames {
        warnings.append("profile_validation_parent_names_too_long".localized)
      }
    }
    
    return ValidationResult(errors: errors, warnings: warnings)
  }
  
  private static func validateChildProfile(_ profile: UserProfile) -> ValidationResult {
    var errors: [AppError] = []
    var warnings: [String] = []
    
    // Date of birth validation
    if let dateOfBirth = profile.dateOfBirth {
      if dateOfBirth > Date() {
        errors.append(.invalidDate)
      } else if dateOfBirth < ProfileValidationRules.maxChildAge {
        warnings.append(String(format: "profile_validation_child_age_too_old".localized, ProfileValidationRules.maxChildAgeYears))
      }
      
      // Check if stage matches age
      let calculatedStage = profile.currentBabyStage
      if calculatedStage != profile.babyStage {
        warnings.append(String(format: "profile_validation_stage_mismatch".localized, calculatedStage.displayName.lowercased()))
      }
    } else {
      errors.append(.profileIncomplete)
    }
    
    return ValidationResult(errors: errors, warnings: warnings)
  }
  
  private static func validateStoryTime(_ storyTime: Date) -> [AppError] {
    let components = Calendar.current.dateComponents([.hour, .minute], from: storyTime)
    
    guard let hour = components.hour,
          let minute = components.minute else {
      return [.invalidDate]
    }
    
    if !ProfileValidationRules.storyTimeValidHours.contains(hour) ||
       !ProfileValidationRules.storyTimeValidMinutes.contains(minute) {
      return [.invalidDate]
    }
    
    return []
  }
  
  private static func validateInterests(_ interests: [String], for stage: BabyStage) -> [String] {
    var warnings: [String] = []
    
    if interests.count > ProfileValidationRules.maxInterests {
      warnings.append("profile_validation_too_many_interests".localized)
    }
    
    // Check for age-appropriate interests
    let profile = UserProfile(name: "temp", babyStage: stage)
    let ageAppropriate = profile.getAgeAppropriateInterests()
    let inappropriate = interests.filter { !ageAppropriate.contains($0) }
    
    if !inappropriate.isEmpty {
      warnings.append(String(format: "profile_validation_inappropriate_interests".localized, stage.displayName.lowercased()))
    }
    
    return warnings
  }
}
