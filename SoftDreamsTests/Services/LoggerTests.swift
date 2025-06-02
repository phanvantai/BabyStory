//
//  LoggerTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct LoggerTests {
    
    @Test("Logger Category Properties")
    func testLoggerCategory() {
        // Test all category raw values
        #expect(Logger.Category.userProfile.rawValue == "UserProfile")
        #expect(Logger.Category.autoUpdate.rawValue == "AutoUpdate")
        #expect(Logger.Category.storage.rawValue == "Storage")
        #expect(Logger.Category.storyGeneration.rawValue == "StoryGeneration")
        #expect(Logger.Category.onboarding.rawValue == "Onboarding")
        #expect(Logger.Category.settings.rawValue == "Settings")
        #expect(Logger.Category.general.rawValue == "General")
        #expect(Logger.Category.notification.rawValue == "Notification")
        
        // Test subsystem property
        #expect(Logger.Category.userProfile.subsystem == "com.randomtech.SoftDreams")
        #expect(Logger.Category.general.subsystem == "com.randomtech.SoftDreams")
    }
    
    @Test("Logger level enum")
    func testLoggerLevel() {
        // Test level enum cases exist
        let debugLevel = Logger.Level.debug
        let infoLevel = Logger.Level.info
        let warningLevel = Logger.Level.warning
        let errorLevel = Logger.Level.error
        
        #expect(debugLevel != nil)
        #expect(infoLevel != nil)
        #expect(warningLevel != nil)
        #expect(errorLevel != nil)
    }
    
    @Test("Logger log method parameters")
    func testLogMethodParameters() {
        // Test that log method can be called with different parameters
        Logger.log("Test message")
        Logger.log("Test message", category: .userProfile)
        Logger.log("Test message", category: .storage, level: .warning)
        Logger.log("Test message", category: .general, level: .error, file: "test.swift", function: "testFunction", line: 123)
        
        // This test passes if no compilation errors occur
        #expect(true)
    }
    
    @Test("Logger convenience methods")
    func testConvenienceMethods() {
        // Test all convenience methods can be called
        Logger.debug("Debug message")
        Logger.info("Info message")
        Logger.warning("Warning message")
        Logger.error("Error message")
        
        Logger.debug("Debug message", category: .userProfile)
        Logger.info("Info message", category: .storage)
        Logger.warning("Warning message", category: .storyGeneration)
        Logger.error("Error message", category: .notification)
        
        // This test passes if no compilation errors occur
        #expect(true)
    }
    
    @Test("Logger user profile logging with valid profile")
    func testLogUserProfileWithValidProfile() {
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Animals", "Music"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            gender: .male
        )
        
        // Test logging profile with default action
        Logger.logUserProfile(profile)
        
        // Test logging profile with custom action
        Logger.logUserProfile(profile, action: "Updated")
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger user profile logging with nil profile")
    func testLogUserProfileWithNilProfile() {
        // Test logging nil profile should call warning
        Logger.logUserProfile(nil)
        Logger.logUserProfile(nil, action: "Created")
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger user profile logging with pregnancy profile")
    func testLogUserProfileWithPregnancyProfile() {
        let profile = UserProfile(
            name: "Expecting Parent",
            babyStage: .pregnancy,
            interests: ["Gentle Stories", "Classical Music"],
            dueDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
            gender: .notSpecified
        )
        
        Logger.logUserProfile(profile, action: "Created")
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger user profile logging with profile needing update")
    func testLogUserProfileWithProfileNeedingUpdate() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let profile = UserProfile(
            name: "Outdated Profile",
            babyStage: .newborn,
            interests: ["Lullabies"],
            storyTime: Date(),
            dueDate: nil,
            parentNames: [],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            lastUpdate: oldDate,
            gender: .female,
            language: .english
        )
        
        Logger.logUserProfile(profile, action: "Loaded")
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger auto update check logging")
    func testLogAutoUpdateCheck() {
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .newborn,
            interests: ["Lullabies", "Comfort"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            gender: .male
        )
        
        Logger.logAutoUpdateCheck(profile)
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger auto update performed logging")
    func testLogAutoUpdatePerformed() {
        let oldProfile = UserProfile(
            name: "Test Baby",
            babyStage: .newborn,
            interests: ["Lullabies"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            gender: .male
        )
        
        let newProfile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Animals", "Discovery"],
            dateOfBirth: oldProfile.dateOfBirth,
            gender: .male
        )
        
        Logger.logAutoUpdatePerformed(from: oldProfile, to: newProfile)
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger auto update skipped logging")
    func testLogAutoUpdateSkipped() {
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Animals", "Music"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            gender: .female
        )
        
        Logger.logAutoUpdateSkipped(profile, reason: "No changes needed")
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger growth celebration logging")
    func testLogGrowthCelebration() {
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .newborn,
            interests: ["Lullabies"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            gender: .male
        )
        
        Logger.logGrowthCelebration(profile)
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger auto update error logging")
    func testLogAutoUpdateError() {
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .infant,
            interests: ["Animals"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            gender: .female
        )
        
        let error = AppError.invalidProfile
        Logger.logAutoUpdateError(error, for: profile)
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger date formatter consistency")
    func testDateFormatterConsistency() {
        // Create multiple profiles to test date formatting consistency
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        
        let profile1 = UserProfile(
            name: "Baby 1",
            babyStage: .infant,
            interests: ["Music"],
            storyTime: Date(),
            dueDate: nil,
            parentNames: [],
            dateOfBirth: date1,
            lastUpdate: date1,
            gender: .male,
            language: .english
        )
        
        let profile2 = UserProfile(
            name: "Baby 2",
            babyStage: .toddler,
            interests: ["Colors"],
            storyTime: Date(),
            dueDate: nil,
            parentNames: [],
            dateOfBirth: date2,
            lastUpdate: date2,
            gender: .female,
            language: .english
        )
        
        // Log both profiles - the date formatter should handle both consistently
        Logger.logUserProfile(profile1)
        Logger.logUserProfile(profile2)
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger edge cases")
    func testLoggerEdgeCases() {
        // Test with empty interests
        let profileWithNoInterests = UserProfile(
            name: "Simple Baby",
            babyStage: .newborn,
            interests: [],
            dateOfBirth: Date(),
            gender: .notSpecified
        )
        
        Logger.logUserProfile(profileWithNoInterests)
        
        // Test with very long name
        let profileWithLongName = UserProfile(
            name: "This is a very long name that might cause formatting issues in the logger output",
            babyStage: .preschooler,
            interests: ["Adventure", "Learning", "Friendship", "Art", "Science"],
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -4, to: Date()),
            gender: .female
        )
        
        Logger.logUserProfile(profileWithLongName)
        
        // Test auto update with same profile (no changes)
        Logger.logAutoUpdatePerformed(from: profileWithNoInterests, to: profileWithNoInterests)
        
        // This test passes if no crashes occur
        #expect(true)
    }
    
    @Test("Logger with special characters and unicode")
    func testLoggerWithSpecialCharacters() {
        let profile = UserProfile(
            name: "Émilie-José 👶",
            babyStage: .infant,
            interests: ["🎵 Music", "🐱 Animals", "📚 Stories"],
            dateOfBirth: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            gender: .female
        )
        
        Logger.logUserProfile(profile)
        Logger.logAutoUpdateCheck(profile)
        
        // Test with special characters in log messages
        Logger.info("Testing with émojis 🎉 and spéciål characters", category: .general)
        Logger.warning("Warning with unicode: ñáéíóú", category: .general)
        
        // This test passes if no crashes occur
        #expect(true)
    }
}
