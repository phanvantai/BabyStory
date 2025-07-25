//
//  EditProfileViewModel.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation
import SwiftUI

class EditProfileViewModel: ObservableObject {
  @Published var name: String = ""
  @Published var babyStage: BabyStage = .toddler
  @Published var gender: Gender = .notSpecified
  @Published var interests: [String] = []
  @Published var storyTime: Date = Date()
  @Published var dueDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
  @Published var parentNames: [String] = []
  @Published var dateOfBirth: Date? = nil
  @Published var language: Language = Language.deviceDefault
  @Published var error: AppError?
  @Published var isLoading: Bool = false
  @Published var showTimePicker: Bool = false
  
  private var originalProfile: UserProfile?
  private let userProfileService: UserProfileServiceProtocol
  private let storyTimeNotificationService: StoryTimeNotificationServiceProtocol
  
  init(userProfileService: UserProfileServiceProtocol? = nil,
       storyTimeNotificationService: StoryTimeNotificationServiceProtocol? = nil) {
    self.userProfileService = userProfileService ?? ServiceFactory.shared.createUserProfileService()
    self.storyTimeNotificationService = storyTimeNotificationService ?? ServiceFactory.shared.createStoryTimeNotificationService()
    loadCurrentProfile()
  }
  
  // MARK: - Computed Properties
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
  
  // Date of birth range (same as onboarding)
  var dateOfBirthRange: ClosedRange<Date> {
    let calendar = Calendar.current
    let maxDate = Date() // Today
    let minDate = calendar.date(byAdding: .year, value: -6, to: Date()) ?? Date()
    return minDate...maxDate
  }
  
  // Current age display text
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
  
  // Validation
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
  
  var canSave: Bool {
    return isValidName && isValidDateOfBirth && isValidParentNames && !isLoading
  }
  
  var hasChanges: Bool {
    guard let original = originalProfile else { return true }
    
    return name != original.name ||
    babyStage != original.babyStage ||
    gender != original.gender ||
    interests != original.interests ||
    parentNames != original.parentNames ||
    dateOfBirth != original.dateOfBirth ||
    dueDate != original.dueDate ||
    language != original.language ||
    !Calendar.current.isDate(storyTime, equalTo: original.storyTime, toGranularity: .minute)
  }
  
  // MARK: - Methods
  func loadCurrentProfile() {
    Logger.info("Loading current profile for editing", category: .userProfile)
    do {
      if let profile = try userProfileService.loadProfile() {
        originalProfile = profile
        
        // Populate fields
        name = profile.name
        babyStage = profile.babyStage
        gender = profile.gender
        interests = profile.interests
        storyTime = profile.storyTime
        parentNames = profile.parentNames
        dateOfBirth = profile.dateOfBirth
        language = profile.language
        
        if let dueDate = profile.dueDate {
          self.dueDate = dueDate
        }
        
        error = nil
        Logger.info("Profile loaded for editing: \(profile.name)", category: .userProfile)
      } else {
        Logger.warning("No profile found to edit", category: .userProfile)
        error = .invalidProfile
      }
    } catch {
      Logger.error("Failed to load profile for editing: \(error.localizedDescription)", category: .userProfile)
      self.error = error as? AppError ?? .dataCorruption
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
      // Set default date of birth based on stage if not already set
      if dateOfBirth == nil {
        setDefaultDateOfBirth()
      }
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
  
  func toggleInterest(_ interest: String) {
    if interests.contains(interest) {
      interests.removeAll { $0 == interest }
    } else {
      interests.append(interest)
    }
  }
  func saveProfile() async -> Bool {
    guard canSave else {
      error = .invalidProfile
      return false
    }
    
    await MainActor.run {
      isLoading = true
      error = nil
    }
    
    Logger.info("Saving updated profile", category: .userProfile)
    
    do {
      let updatedProfile = UserProfile(
        name: name,
        babyStage: babyStage,
        interests: interests,
        storyTime: storyTime,
        dueDate: isPregnancy ? dueDate : nil,
        parentNames: parentNames,
        dateOfBirth: dateOfBirth,
        lastUpdate: Date(), // Update the last update timestamp
        gender: gender,
        language: language
      )
      
      try userProfileService.saveProfile(updatedProfile)
      
      // Update LanguageManager if language changed
      if let originalLanguage = originalProfile?.language, originalLanguage != language {
        await MainActor.run {
          LanguageManager.shared.updateLanguage(language.code)
          Logger.info("Language updated to: \(language.code)", category: .userProfile)
        }
      }
      
      // Handle story time notification updates
      if let original = originalProfile {
        if !Calendar.current.isDate(original.storyTime, equalTo: storyTime, toGranularity: .minute) {
          // Story time has changed, update notifications
          Logger.info("Story time changed from \(original.storyTime.formatted(date: .omitted, time: .shortened)) to \(storyTime.formatted(date: .omitted, time: .shortened)), updating notifications", category: .notification)
          _ = await storyTimeNotificationService.scheduleStoryTimeReminder(for: storyTime, babyName: original.displayName)
        }
      } else {
        // New profile, schedule notifications
        _ = await storyTimeNotificationService.scheduleStoryTimeReminder(for: storyTime, babyName: updatedProfile.displayName)
      }
      
      // Handle due date notification updates
      let notificationService = ServiceFactory.shared.createDueDateNotificationService()
      
      // Check if this is a significant change that affects notifications
      let wasPregnancy = originalProfile?.isPregnancy ?? false
      let dueDateChanged = originalProfile?.dueDate != updatedProfile.dueDate
      
      if wasPregnancy && !updatedProfile.isPregnancy {
        // Changed from pregnancy to born baby - cancel all notifications
        notificationService.cancelAllDueDateNotifications()
        Logger.info("Profile changed from pregnancy to born baby, cancelled due date notifications", category: .userProfile)
      } else if updatedProfile.isPregnancy && (dueDateChanged || !wasPregnancy) {
        // Due date changed or switched to pregnancy - reschedule notifications
        await notificationService.scheduleNotificationsForCurrentProfile()
        Logger.info("Due date updated, rescheduled notifications", category: .userProfile)
      } else if updatedProfile.isPregnancy {
        // Still pregnancy but profile manually updated - handle notification update
        notificationService.handleProfileUpdate()
      }
      
      await MainActor.run {
        isLoading = false
        Logger.info("Profile updated successfully for: \(name)", category: .userProfile)
      }
      
      return true
    } catch {
      await MainActor.run {
        Logger.error("Failed to save profile updates: \(error.localizedDescription)", category: .userProfile)
        self.error = error as? AppError ?? .dataCorruption
        isLoading = false
      }
      return false
    }
  }
  
  func cancelEditing() {
    // Reset to original values if they exist
    if let original = originalProfile {
      name = original.name
      babyStage = original.babyStage
      gender = original.gender
      interests = original.interests
      storyTime = original.storyTime
      parentNames = original.parentNames
      dateOfBirth = original.dateOfBirth
      language = original.language
      
      if let dueDate = original.dueDate {
        self.dueDate = dueDate
      }
    }
    error = nil
  }
}
