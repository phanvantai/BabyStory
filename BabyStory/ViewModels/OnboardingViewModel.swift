import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
  @Published var name: String = ""
  @Published var babyStage: BabyStage = .toddler
  @Published var interests: [String] = []
  @Published var storyTime: Date = Date()
  @Published var dueDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
  @Published var parentNames: [String] = []
  @Published var dateOfBirth: Date? = nil
  @Published var gender: Gender = .notSpecified
  @Published var step: Int = 0
  @Published var error: AppError?
  
  init() {
    // Initialize with default values based on the default baby stage
    initializeForCurrentBabyStage()
  }
  
  // Initialization helper method
  private func initializeForCurrentBabyStage() {
    // Initialize parent names if pregnancy and empty
    if isPregnancy && parentNames.isEmpty {
      addParentName()
    }
    
    // Set default date of birth based on baby stage if it's not pregnancy
    if babyStage != .pregnancy {
      setDefaultDateOfBirth()
    }
  }
  
  // Computed properties for UI state
  var isPregnancy: Bool {
    return babyStage == .pregnancy
  }
  
  var shouldShowDateOfBirth: Bool {
    return !isPregnancy
  }
  
  var shouldShowDueDate: Bool {
    return isPregnancy
  }
  
  var shouldShowParentNames: Bool {
    return isPregnancy
  }
  
  // Date of birth range
  var dateOfBirthRange: ClosedRange<Date> {
    let calendar = Calendar.current
    let maxDate = Date() // Today
    let minDate = calendar.date(byAdding: .year, value: -6, to: Date()) ?? Date()
    return minDate...maxDate
  }
  
  // Computed age from date of birth for display
  var currentAge: Int? {
    guard let dateOfBirth = dateOfBirth else { return nil }
    
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
    
    if let years = ageComponents.year, let months = ageComponents.month {
      if years < 2 {
        return years * 12 + months // Return months for babies under 2
      } else {
        return years // Return years for older children
      }
    }
    return nil
  }
  
  var ageDisplayText: String {
    guard let dateOfBirth = dateOfBirth else { return "Not set" }
    
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
    
    if let years = ageComponents.year, let months = ageComponents.month {
      if years < 2 {
        let totalMonths = years * 12 + months
        return totalMonths == 1 ? "1 month old" : "\(totalMonths) months old"
      } else {
        return years == 1 ? "1 year old" : "\(years) years old"
      }
    }
    
    return "Unknown age"
  }
  
  // Available interests based on baby stage
  var availableInterests: [String] {
    switch babyStage {
    case .pregnancy:
      return [
        "Classical Music",
        "Nature Sounds",
        "Gentle Stories",
        "Parent Bonding",
        "Relaxation",
        "Love & Care"
      ]
    case .newborn:
      return [
        "Lullabies",
        "Gentle Sounds",
        "Soft Colors",
        "Comfort",
        "Sleep",
        "Feeding Time"
      ]
    case .infant:
      return [
        "Peek-a-boo",
        "Simple Sounds",
        "Textures",
        "Movement",
        "Smiles",
        "Discovery"
      ]
    case .toddler:
      return [
        "Animals",
        "Colors",
        "Numbers",
        "Vehicles",
        "Nature",
        "Family",
        "Friends",
        "Playing"
      ]
    case .preschooler:
      return [
        "Adventure",
        "Magic",
        "Friendship",
        "Learning",
        "Imagination",
        "Problem Solving",
        "Emotions",
        "School"
      ]
    }
  }
  
  // Validation methods
  var isValidName: Bool {
    return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  
  var isValidDateOfBirth: Bool {
    if isPregnancy {
      return true // Date of birth not required for pregnancy
    }
    return dateOfBirth != nil
  }
  
  var isValidParentNames: Bool {
    if !isPregnancy {
      return true // Parent names not required for born babies
    }
    return !parentNames.isEmpty && parentNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }
  
  var canProceed: Bool {
    return isValidName && isValidDateOfBirth && isValidParentNames
  }
  
  // Helper methods
  func addParentName() {
    if parentNames.count < 2 {
      parentNames.append("")
    }
  }
  
  func removeParentName(at index: Int) {
    if index < parentNames.count {
      parentNames.remove(at: index)
    }
  }
  
  func updateBabyStage(_ newStage: BabyStage) {
    babyStage = newStage
    
    // Clear date of birth if switching to pregnancy
    if newStage == .pregnancy {
      dateOfBirth = nil
      if parentNames.isEmpty {
        parentNames = [""] // Start with one empty parent name
      }
    } else {
      // Set default date of birth based on stage
      setDefaultDateOfBirth()
      parentNames.removeAll()
    }
    
    // Clear interests when stage changes
    interests.removeAll()
  }
  
  private func setDefaultDateOfBirth() {
    let calendar = Calendar.current
    
    switch babyStage {
    case .newborn:
      // 1 month old
      dateOfBirth = calendar.date(byAdding: .month, value: -1, to: Date())
    case .infant:
      // 6 months old
      dateOfBirth = calendar.date(byAdding: .month, value: -6, to: Date())
    case .toddler:
      // 2 years old
      dateOfBirth = calendar.date(byAdding: .year, value: -2, to: Date())
    case .preschooler:
      // 4 years old
      dateOfBirth = calendar.date(byAdding: .year, value: -4, to: Date())
    case .pregnancy:
      dateOfBirth = nil
    }
  }
  
  // Age adjustment methods removed - now using date picker for date of birth
  
  func toggleInterest(_ interest: String) {
    if interests.contains(interest) {
      interests.removeAll { $0 == interest }
    } else {
      interests.append(interest)
    }
  }
  
  func saveProfile() {
    Logger.info("Starting profile save from onboarding", category: .onboarding)
    do {
      let profile = UserProfile(
        name: name,
        babyStage: babyStage,
        interests: interests,
        storyTime: storyTime,
        dueDate: isPregnancy ? dueDate : nil,
        parentNames: isPregnancy ? parentNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } : [],
        dateOfBirth: isPregnancy ? nil : dateOfBirth,
        lastUpdate: Date(),
        gender: gender
      )
      try StorageManager.shared.saveProfile(profile)
      error = nil
      Logger.info("Onboarding profile save completed successfully", category: .onboarding)
    } catch {
      Logger.error("Failed to save profile from onboarding: \(error.localizedDescription)", category: .onboarding)
      self.error = .profileSaveFailed
    }
  }
  
  // Returns time-based story recommendations based on the selected story time
  func getStoryRecommendations() -> [String] {
    let hour = Calendar.current.component(.hour, from: storyTime)
    
    switch hour {
    case 6...11:
      return ["Morning Adventures", "Wake-up Stories", "Breakfast Tales", "Sunny Day Fun"]
    case 12...17:
      return ["Afternoon Play", "Learning Stories", "Outdoor Adventures", "Friend Tales"]
    case 18...21:
      return ["Bedtime Stories", "Calm Adventures", "Dream Journeys", "Goodnight Tales"]
    default:
      return ["Peaceful Dreams", "Quiet Stories", "Sleep Adventures", "Gentle Tales"]
    }
  }
}
