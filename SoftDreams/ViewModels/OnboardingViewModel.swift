import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
  // Language selection
  @Published var selectedLanguage: Language = Language.preferred
  
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
  @Published var hasSelectedBabyStatus: Bool = false
  
  // Notification permission handling
  @Published var showNotificationPermissionPrompt: Bool = false
  @Published var notificationPermissionContext: PermissionContext = .pregnancyReminders
  
  init() {
    // Don't initialize values until user makes their choice
    // The user will first select pregnancy vs born baby status
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
    guard let dateOfBirth = dateOfBirth else { return "edit_profile_age_not_set".localized }
    
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
    
    if let years = ageComponents.year, let months = ageComponents.month {
      if years < 2 {
        let totalMonths = years * 12 + months
        return totalMonths == 1 ? "edit_profile_age_one_month".localized : String(format: "edit_profile_age_months_format".localized, totalMonths)
      } else {
        return years == 1 ? "edit_profile_age_one_year".localized : String(format: "edit_profile_age_years_format".localized, years)
      }
    }
    
    return "edit_profile_age_unknown".localized
  }
  
  // Available interests based on baby stage
  var availableInterests: [String] {
    return babyStage.availableInterests
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
    // First check if user has made their initial choice
    guard hasSelectedBabyStatus else { return false }
    
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
    hasSelectedBabyStatus = true
    
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
    
    // Clear interests when stage changes to avoid invalid interests
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
        gender: gender,
        language: selectedLanguage
      )
      try StorageManager.shared.saveProfile(profile)
      error = nil
      Logger.info("Onboarding profile save completed successfully", category: .onboarding)
      
      // Setup due date notifications for pregnancy profiles
      if isPregnancy {
        Task {
          let notificationService = ServiceFactory.shared.createDueDateNotificationService()
          let permissionAlreadyGranted = await notificationService.setupDueDateNotifications()
          
          if !permissionAlreadyGranted && notificationService.shouldShowPermissionExplanation() {
            // Show permission prompt on main thread
            await MainActor.run {
              showNotificationPermissionPrompt = true
            }
          }
        }
      }
      
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
      return [
        "onboarding_story_morning_adventures".localized,
        "onboarding_story_wake_up_stories".localized,
        "onboarding_story_breakfast_tales".localized,
        "onboarding_story_sunny_day_fun".localized
      ]
    case 12...17:
      return [
        "onboarding_story_afternoon_play".localized,
        "onboarding_story_learning_stories".localized,
        "onboarding_story_outdoor_adventures".localized,
        "onboarding_story_friend_tales".localized
      ]
    case 18...21:
      return [
        "onboarding_story_bedtime_stories".localized,
        "onboarding_story_calm_adventures".localized,
        "onboarding_story_dream_journeys".localized,
        "onboarding_story_goodnight_tales".localized
      ]
    default:
      return [
        "onboarding_story_peaceful_dreams".localized,
        "onboarding_story_quiet_stories".localized,
        "onboarding_story_sleep_adventures".localized,
        "onboarding_story_gentle_tales".localized
      ]
    }
  }
  
  // MARK: - Notification Permission Methods
  
  /// Handles when user grants notification permission
  func handleNotificationPermissionGranted() {
    Task {
      let notificationService = ServiceFactory.shared.createDueDateNotificationService()
      _ = await notificationService.requestNotificationPermission()
    }
    showNotificationPermissionPrompt = false
  }
  
  /// Handles when user denies notification permission
  func handleNotificationPermissionDenied() {
    showNotificationPermissionPrompt = false
    // Continue without notifications - user can enable them later in settings
  }
}
