//
//  AutoProfileUpdateService.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation

// MARK: - Auto Profile Update Service
/// Service responsible for automatically updating user profile information based on age progression and other criteria
class AutoProfileUpdateService: AutoProfileUpdateServiceProtocol {
  
  // MARK: - Properties
  private let userProfileService: UserProfileServiceProtocol
  private let notificationService: DueDateNotificationService
  
  // MARK: - Initialization
  init(userProfileService: UserProfileServiceProtocol? = nil, notificationService: DueDateNotificationService? = nil) {
    self.userProfileService = userProfileService ?? ServiceFactory.shared.createUserProfileService()
    self.notificationService = notificationService ?? ServiceFactory.shared.createDueDateNotificationService()
  }
  
  // MARK: - Public Methods
  
  /// Performs automatic profile updates and returns update results
  /// - Parameter profile: Optional user profile. If provided, avoids loading the profile again from storage
  /// - Returns: AutoUpdateResult containing information about what was updated
  func performAutoUpdate(profile: UserProfile? = nil) async -> AutoUpdateResult {
    Logger.info("Starting automatic profile update check", category: .autoUpdate)
    
    do {
      // Use the provided profile if available, otherwise load from storage
      let currentProfile: UserProfile
      if let existingProfile = profile {
        currentProfile = existingProfile
      } else {
        guard let loadedProfile = try userProfileService.loadProfile() else {
          Logger.logAutoUpdateSkipped(UserProfile(name: "Unknown"), reason: "No profile found")
          return AutoUpdateResult()
        }
        currentProfile = loadedProfile
      }
      
      // Log the current state before checking for updates
      Logger.logAutoUpdateCheck(currentProfile)
      
      var updatedProfile = currentProfile
      var result = AutoUpdateResult()
      
      // Check for stage progression
      if let stageUpdate = checkForStageProgression(profile: currentProfile) {
        updatedProfile.babyStage = stageUpdate.newStage
        
        // Special handling for pregnancy-to-newborn transition
        if currentProfile.babyStage == .pregnancy && stageUpdate.newStage == .newborn {
          // Set date of birth to due date when transitioning from pregnancy to newborn
          updatedProfile.dateOfBirth = currentProfile.dueDate
          updatedProfile.dueDate = nil // Clear due date as it's no longer needed
          Logger.info("Pregnancy-to-newborn transition: Setting dateOfBirth to due date", category: .autoUpdate)
          
          // Cancel due date notifications since baby is now born
          notificationService.cancelAllDueDateNotifications()
        }
        
        result.stageProgression = stageUpdate
        Logger.info("Stage progression detected: \(currentProfile.babyStage.displayName) → \(stageUpdate.newStage.displayName)", category: .autoUpdate)
        
        // Log growth celebration if applicable
        Logger.logGrowthCelebration(updatedProfile)
      }
      
      // Update interests based on new stage
      if let interestUpdate = updateInterests(for: updatedProfile, originalProfile: currentProfile) {
        updatedProfile.interests = interestUpdate.newInterests
        result.interestUpdate = interestUpdate
        Logger.info("Interests updated for new stage: \(interestUpdate.newInterests.count) interests", category: .autoUpdate)
      }
      
      // Update metadata
      if result.hasUpdates {
        updatedProfile.lastUpdate = Date()
        result.profileMetadata = ProfileMetadataUpdate(
          previousLastUpdate: currentProfile.lastUpdate,
          newLastUpdate: updatedProfile.lastUpdate
        )
      }
      
      // Save updated profile if changes were made
      if result.hasUpdates {
        try userProfileService.saveProfile(updatedProfile)
        Logger.logAutoUpdatePerformed(from: currentProfile, to: updatedProfile)
        
        // Handle notification updates
        notificationService.handleProfileUpdate()
      } else {
        Logger.logAutoUpdateSkipped(currentProfile, reason: "No updates needed")
      }
      
      // Setup or update due date notifications for pregnancy profiles
      if updatedProfile.isPregnancy && updatedProfile.dueDate != nil {
        await notificationService.scheduleNotificationsForCurrentProfile()
      }
      
      return result
      
    } catch {
      Logger.logAutoUpdateError(error, for: UserProfile(name: "Unknown"))
      return AutoUpdateResult(error: error)
    }
  }
  
  /// Updates profile if needed - simplified interface for basic auto-update functionality
  func updateProfileIfNeeded() async {
    let _ = await performAutoUpdate()
  }
  
  /// Sets up due date notifications for the current profile
  /// Only schedules if permission is already granted, doesn't request permission
  func setupDueDateNotifications() async {
    let _ = await notificationService.setupDueDateNotifications()
    // Note: This method now only schedules if permission exists
    // Permission requests should be handled by the UI layer
  }

  /// Checks if profile needs auto-updating without performing the update
  /// - Parameter profile: Optional user profile. If provided, avoids loading the profile again from storage
  /// - Returns: Bool indicating if auto-update is needed
  func needsAutoUpdate(profile: UserProfile? = nil) -> Bool {
    do {
      // Use the provided profile if available, otherwise load from storage
      let userProfile: UserProfile
      if let existingProfile = profile {
        userProfile = existingProfile
      } else {
        guard let loadedProfile = try userProfileService.loadProfile() else { return false }
        userProfile = loadedProfile
      }
      
      let needsUpdate = userProfile.hasGrownToNewStage() || userProfile.needsUpdate
      
      if needsUpdate {
        Logger.debug("Profile needs auto-update: stage change=\(userProfile.hasGrownToNewStage()), regular update=\(userProfile.needsUpdate)", category: .autoUpdate)
      }
      
      return needsUpdate
    } catch {
      Logger.logAutoUpdateError(error, for: UserProfile(name: "Unknown"))
      return false
    }
  }
  
  // MARK: - Private Methods
  
  /// Checks for baby stage progression based on age
  private func checkForStageProgression(profile: UserProfile) -> StageProgressionUpdate? {
    guard profile.hasGrownToNewStage() else { return nil }
    
    let oldStage = profile.babyStage
    let newStage = profile.currentBabyStage
    
    return StageProgressionUpdate(
      previousStage: oldStage,
      newStage: newStage,
      ageInMonths: profile.currentAge,
      growthMessage: profile.getGrowthMessage()
    )
  }
  
  /// Updates interests to be age-appropriate for the current stage
  private func updateInterests(for updatedProfile: UserProfile, originalProfile: UserProfile) -> InterestUpdate? {
    // Only update interests if stage changed
    guard updatedProfile.babyStage != originalProfile.babyStage else { return nil }
    
    let newAvailableInterests = getAvailableInterests(for: updatedProfile.babyStage)
    let currentInterests = originalProfile.interests
    
    // Filter current interests to keep only those that are still age-appropriate
    let filteredInterests = currentInterests.filter { newAvailableInterests.contains($0) }
    
    // Add suggested interests if we have fewer than 3
    var finalInterests = filteredInterests
    var suggestedInterests = getSuggestedInterests(for: updatedProfile.babyStage, excluding: filteredInterests)
    
    while finalInterests.count < 3 && !suggestedInterests.isEmpty {
      if let suggestion = suggestedInterests.first {
        finalInterests.append(suggestion)
        suggestedInterests.removeFirst()
      } else {
        break
      }
    }
    
    // Only return update if interests actually changed
    guard finalInterests != currentInterests else { return nil }
    
    return InterestUpdate(
      previousInterests: currentInterests,
      newInterests: finalInterests,
      removedInterests: currentInterests.filter { !finalInterests.contains($0) },
      addedInterests: finalInterests.filter { !currentInterests.contains($0) }
    )
  }
  
  /// Gets available interests for a specific baby stage
  private func getAvailableInterests(for stage: BabyStage) -> [String] {
    return stage.availableInterests
  }
  
  /// Gets suggested interests for a stage, prioritizing popular ones
  private func getSuggestedInterests(for stage: BabyStage, excluding existingInterests: [String]) -> [String] {
    let allAvailable = getAvailableInterests(for: stage)
    let suggestions = allAvailable.filter { !existingInterests.contains($0) }
    
    // Prioritize certain interests based on stage
    let prioritized: [String]
    switch stage {
    case .pregnancy:
      prioritized = ["Gentle Stories", "Classical Music", "Love & Care"]
    case .newborn:
      prioritized = ["Lullabies", "Comfort", "Sleep"]
    case .infant:
      prioritized = ["Discovery", "Simple Sounds", "Movement"]
    case .toddler:
      prioritized = ["Animals", "Colors", "Family"]
    case .preschooler:
      prioritized = ["Adventure", "Learning", "Friendship"]
    }
    
    // Return prioritized suggestions first, then others
    let prioritizedFiltered = prioritized.filter { suggestions.contains($0) }
    let remaining = suggestions.filter { !prioritized.contains($0) }
    
    return prioritizedFiltered + remaining
  }
}

// MARK: - Auto Update Result Models

/// Contains the results of an automatic profile update
struct AutoUpdateResult {
  var stageProgression: StageProgressionUpdate?
  var interestUpdate: InterestUpdate?
  var profileMetadata: ProfileMetadataUpdate?
  var error: Error?
  
  /// Whether any updates were performed
  var hasUpdates: Bool {
    return stageProgression != nil || interestUpdate != nil
  }
  
  /// Number of updates performed
  var updateCount: Int {
    var count = 0
    if stageProgression != nil { count += 1 }
    if interestUpdate != nil { count += 1 }
    if profileMetadata != nil { count += 1 }
    return count
  }
  
  /// Success status
  var isSuccess: Bool {
    return error == nil
  }
}

/// Information about stage progression update
struct StageProgressionUpdate {
  let previousStage: BabyStage
  let newStage: BabyStage
  let ageInMonths: Int?
  let growthMessage: String?
}

/// Information about interest updates
struct InterestUpdate {
  let previousInterests: [String]
  let newInterests: [String]
  let removedInterests: [String]
  let addedInterests: [String]
}

/// Information about profile metadata updates
struct ProfileMetadataUpdate {
  let previousLastUpdate: Date
  let newLastUpdate: Date
}
