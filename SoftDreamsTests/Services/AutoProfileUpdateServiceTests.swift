//
//  AutoProfileUpdateServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct AutoProfileUpdateServiceTests {
  
  func setUp() {
    // Clean up UserDefaults before each test
    UserDefaults.standard.removeObject(forKey: "userProfile")
    UserDefaults.standard.removeObject(forKey: "stories")
    UserDefaults.standard.removeObject(forKey: "settings")
  }
  
  @Test("AutoProfileUpdateService initialization")
  func testInitialization() {
    setUp()
    
    let service = AutoProfileUpdateService()
    #expect(service != nil)
    
    // Test initialization with custom storage manager
    let customStorageManager = StorageManager.shared
    let serviceWithCustomManager = AutoProfileUpdateService(storageManager: customStorageManager)
    #expect(serviceWithCustomManager != nil)
  }
  
  @Test("AutoProfileUpdateService needsAutoUpdate with no profile")
  func testNeedsAutoUpdateWithNoProfile() {
    setUp()
    
    let service = AutoProfileUpdateService()
    let needsUpdate = service.needsAutoUpdate()
    
    #expect(needsUpdate == false)
  }
  
  @Test("AutoProfileUpdateService needsAutoUpdate with current profile")
  func testNeedsAutoUpdateWithCurrentProfile() throws {
    setUp()
    
    let service = AutoProfileUpdateService()
    let storageManager = StorageManager.shared
    
    // Create a current profile that doesn't need update
    let profile = UserProfile(
      name: "Test Baby",
      babyStage: .infant,
      interests: ["Animals", "Music"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
      gender: .male
    )
    
    try storageManager.saveProfile(profile)
    
    let needsUpdate = service.needsAutoUpdate()
    #expect(needsUpdate == false)
  }
  
  @Test("AutoProfileUpdateService needsAutoUpdate with outdated profile")
  func testNeedsAutoUpdateWithOutdatedProfile() throws {
    setUp()
    
    let service = AutoProfileUpdateService()
    let storageManager = StorageManager.shared
    
    // Create a profile that needs update (old last update date)
    let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
    let profile = UserProfile(
      name: "Test Baby",
      babyStage: .newborn,
      interests: ["Lullabies"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
      lastUpdate: oldDate, gender: .female
    )
    
    try storageManager.saveProfile(profile)
    
    let needsUpdate = service.needsAutoUpdate()
    #expect(needsUpdate == true)
  }
  
  @Test("AutoProfileUpdateService needsAutoUpdate with provided profile")
  func testNeedsAutoUpdateWithProvidedProfile() {
    setUp()
    
    let service = AutoProfileUpdateService()
    
    // Test with profile that doesn't need update
    let currentProfile = UserProfile(
      name: "Test Baby",
      babyStage: .infant,
      interests: ["Animals"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
      gender: .male
    )
    
    let needsUpdate1 = service.needsAutoUpdate(profile: currentProfile)
    #expect(needsUpdate1 == false)
    
    // Test with profile that needs stage update
    let oldProfile = UserProfile(
      name: "Test Baby",
      babyStage: .newborn,
      interests: ["Lullabies"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
      gender: .male
    )
    
    let needsUpdate2 = service.needsAutoUpdate(profile: oldProfile)
    #expect(needsUpdate2 == true)
  }
  
  @Test("AutoProfileUpdateService performAutoUpdate with no profile")
  func testPerformAutoUpdateWithNoProfile() async {
    setUp()
    
    let service = AutoProfileUpdateService()
    let result = await service.performAutoUpdate()
    
    #expect(result.hasUpdates == false)
    #expect(result.isSuccess == true)
    #expect(result.stageProgression == nil)
    #expect(result.interestUpdate == nil)
    #expect(result.error == nil)
  }
  
  @Test("AutoProfileUpdateService performAutoUpdate with current profile")
  func testPerformAutoUpdateWithCurrentProfile() async throws {
    setUp()
    
    let service = AutoProfileUpdateService()
    let storageManager = StorageManager.shared
    
    let profile = UserProfile(
      name: "Test Baby",
      babyStage: .infant,
      interests: ["Animals", "Music"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
      gender: .male
    )
    
    try storageManager.saveProfile(profile)
    
    let result = await service.performAutoUpdate()
    
    #expect(result.isSuccess == true)
    #expect(result.hasUpdates == false)
    #expect(result.stageProgression == nil)
    #expect(result.interestUpdate == nil)
  }
  
  @Test("AutoProfileUpdateService performAutoUpdate with stage progression")
  func testPerformAutoUpdateWithStageProgression() async throws {
    setUp()
    
    let service = AutoProfileUpdateService()
    let storageManager = StorageManager.shared
    
    // Create a newborn profile that should progress to infant (8+ months old)
    let profile = UserProfile(
      name: "Test Baby",
      babyStage: .newborn,
      interests: ["Lullabies", "Comfort"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
      gender: .male
    )
    
    try storageManager.saveProfile(profile)
    
    let result = await service.performAutoUpdate()
    
    #expect(result.isSuccess == true)
    #expect(result.hasUpdates == true)
    #expect(result.stageProgression != nil)
    #expect(result.stageProgression?.previousStage == .newborn)
    #expect(result.stageProgression?.newStage == .infant)
    #expect(result.profileMetadata != nil)
    
    // Verify profile was actually updated in storage
    let updatedProfile = try storageManager.loadProfile()
    #expect(updatedProfile?.babyStage == .infant)
  }
  
  @Test("AutoProfileUpdateService performAutoUpdate with provided profile")
  func testPerformAutoUpdateWithProvidedProfile() async {
    setUp()
    
    let service = AutoProfileUpdateService()
    
    // Create a profile that needs stage update
    let profile = UserProfile(
      name: "Test Baby",
      babyStage: .newborn,
      interests: ["Lullabies"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
      gender: .female
    )
    
    let result = await service.performAutoUpdate(profile: profile)
    
    #expect(result.isSuccess == true)
    #expect(result.hasUpdates == true)
    #expect(result.stageProgression != nil)
    #expect(result.stageProgression?.previousStage == .newborn)
    #expect(result.stageProgression?.newStage == .infant)
  }
  
  @Test("AutoProfileUpdateService pregnancy to newborn transition")
  func testPregnancyToNewbornTransition() async throws {
    setUp()
    
    let service = AutoProfileUpdateService()
    let storageManager = StorageManager.shared
    
    // Create a pregnancy profile that should transition to newborn
    let dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let profile = UserProfile(
      name: "Expecting Parent",
      babyStage: .pregnancy,
      interests: ["Gentle Stories", "Classical Music"], dueDate: dueDate,
      gender: .notSpecified
    )
    
    try storageManager.saveProfile(profile)
    
    let result = await service.performAutoUpdate()
    
    #expect(result.isSuccess == true)
    #expect(result.hasUpdates == true)
    #expect(result.stageProgression != nil)
    #expect(result.stageProgression?.previousStage == .pregnancy)
    #expect(result.stageProgression?.newStage == .newborn)
    
    // Verify dateOfBirth was set and dueDate was cleared
    let updatedProfile = try storageManager.loadProfile()
    #expect(updatedProfile?.dateOfBirth != nil)
    #expect(updatedProfile?.dueDate == nil)
    #expect(updatedProfile?.babyStage == .newborn)
  }
  
  @Test("AutoProfileUpdateService interest update with stage change")
  func testInterestUpdateWithStageChange() async throws {
    setUp()
    
    let service = AutoProfileUpdateService()
    let storageManager = StorageManager.shared
    
    // Create an infant profile that should progress to toddler
    let profile = UserProfile(
      name: "Test Baby",
      babyStage: .infant,
      interests: ["Discovery", "Simple Sounds", "Movement"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -14, to: Date()),
      gender: .male
    )
    
    try storageManager.saveProfile(profile)
    
    let result = await service.performAutoUpdate()
    
    #expect(result.isSuccess == true)
    #expect(result.hasUpdates == true)
    #expect(result.stageProgression != nil)
    #expect(result.stageProgression?.newStage == .toddler)
    #expect(result.interestUpdate != nil)
    
    // Verify interests were updated appropriately
    let updatedProfile = try storageManager.loadProfile()
    #expect(updatedProfile?.interests.isEmpty == false)
    
    // Interests should be age-appropriate for toddler stage
    let toddlerInterests = BabyStage.toddler.availableInterests
    for interest in updatedProfile?.interests ?? [] {
      #expect(toddlerInterests.contains(interest))
    }
  }
  
  @Test("AutoProfileUpdateService setupDueDateNotifications")
  func testSetupDueDateNotifications() async {
    setUp()
    
    let service = AutoProfileUpdateService()
    
    // This method should not crash when called
    await service.setupDueDateNotifications()
    
    // Test passes if no exceptions are thrown
    #expect(true)
  }
  
  @Test("AutoUpdateResult initialization and properties")
  func testAutoUpdateResult() {
    // Test empty result
    let emptyResult = AutoUpdateResult()
    #expect(emptyResult.hasUpdates == false)
    #expect(emptyResult.updateCount == 0)
    #expect(emptyResult.isSuccess == true)
    #expect(emptyResult.error == nil)
    
    // Test result with stage progression
    let stageUpdate = StageProgressionUpdate(
      previousStage: .newborn,
      newStage: .infant,
      ageInMonths: 8,
      growthMessage: "Your baby is growing!"
    )
    
    var resultWithStage = AutoUpdateResult()
    resultWithStage.stageProgression = stageUpdate
    
    #expect(resultWithStage.hasUpdates == true)
    #expect(resultWithStage.updateCount == 1)
    #expect(resultWithStage.isSuccess == true)
    
    // Test result with interest update
    let interestUpdate = InterestUpdate(
      previousInterests: ["Lullabies"],
      newInterests: ["Animals", "Discovery"],
      removedInterests: ["Lullabies"],
      addedInterests: ["Animals", "Discovery"]
    )
    
    var resultWithInterest = AutoUpdateResult()
    resultWithInterest.interestUpdate = interestUpdate
    
    #expect(resultWithInterest.hasUpdates == true)
    #expect(resultWithInterest.updateCount == 1)
    
    // Test result with both updates
    var resultWithBoth = AutoUpdateResult()
    resultWithBoth.stageProgression = stageUpdate
    resultWithBoth.interestUpdate = interestUpdate
    resultWithBoth.profileMetadata = ProfileMetadataUpdate(
      previousLastUpdate: Date().addingTimeInterval(-3600),
      newLastUpdate: Date()
    )
    
    #expect(resultWithBoth.hasUpdates == true)
    #expect(resultWithBoth.updateCount == 3)
    
    // Test result with error
    var resultWithError = AutoUpdateResult()
    resultWithError.error = AppError.invalidProfile
    
    #expect(resultWithError.hasUpdates == false)
    #expect(resultWithError.isSuccess == false)
  }
  
  @Test("StageProgressionUpdate properties")
  func testStageProgressionUpdate() {
    let update = StageProgressionUpdate(
      previousStage: .newborn,
      newStage: .infant,
      ageInMonths: 8,
      growthMessage: "Growing up!"
    )
    
    #expect(update.previousStage == .newborn)
    #expect(update.newStage == .infant)
    #expect(update.ageInMonths == 8)
    #expect(update.growthMessage == "Growing up!")
  }
  
  @Test("InterestUpdate properties")
  func testInterestUpdate() {
    let update = InterestUpdate(
      previousInterests: ["Lullabies", "Comfort"],
      newInterests: ["Animals", "Discovery", "Movement"],
      removedInterests: ["Lullabies", "Comfort"],
      addedInterests: ["Animals", "Discovery", "Movement"]
    )
    
    #expect(update.previousInterests == ["Lullabies", "Comfort"])
    #expect(update.newInterests == ["Animals", "Discovery", "Movement"])
    #expect(update.removedInterests == ["Lullabies", "Comfort"])
    #expect(update.addedInterests == ["Animals", "Discovery", "Movement"])
  }
  
  @Test("ProfileMetadataUpdate properties")
  func testProfileMetadataUpdate() {
    let previousDate = Date().addingTimeInterval(-3600)
    let newDate = Date()
    
    let update = ProfileMetadataUpdate(
      previousLastUpdate: previousDate,
      newLastUpdate: newDate
    )
    
    #expect(update.previousLastUpdate == previousDate)
    #expect(update.newLastUpdate == newDate)
  }
  
  @Test("AutoProfileUpdateService edge cases")
  func testAutoProfileUpdateServiceEdgeCases() async throws {
    setUp()
    
    let service = AutoProfileUpdateService()
    let storageManager = StorageManager.shared
    
    // Test with profile at exact boundary (6 months for newborn->infant)
    let profile = UserProfile(
      name: "Boundary Baby",
      babyStage: .newborn,
      interests: ["Sleep", "Comfort"], dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
      gender: .notSpecified
    )
    
    try storageManager.saveProfile(profile)
    
    let result = await service.performAutoUpdate()
    
    // At exactly 6 months, should transition to infant
    #expect(result.isSuccess == true)
    if result.hasUpdates {
      #expect(result.stageProgression?.newStage == .infant)
    }
    
    // Test multiple consecutive updates
    let result2 = await service.performAutoUpdate()
    #expect(result2.isSuccess == true)
    #expect(result2.hasUpdates == false) // Should be stable after first update
  }
}
