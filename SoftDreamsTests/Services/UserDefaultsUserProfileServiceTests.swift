import Testing
import Foundation
@testable import SoftDreams

struct UserDefaultsUserProfileServiceTests {
    
    init() {
        // Clean up before each test
        UserDefaults.standard.removeObject(forKey: "user_profile")
    }
    
    deinit {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "user_profile")
    }
    
    @Test("Save and load profile successfully")
    func testSaveAndLoadProfile() throws {
        let service = UserDefaultsUserProfileService()
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
            interests: ["dragons", "adventure"],
            motherDueDate: nil
        )
        
        try service.saveProfile(profile)
        let loadedProfile = try service.loadProfile()
        
        #expect(loadedProfile != nil)
        #expect(loadedProfile?.name == "Test Child")
        #expect(loadedProfile?.gender == .boy)
        #expect(loadedProfile?.interests == ["dragons", "adventure"])
        #expect(loadedProfile?.id == profile.id)
    }
    
    @Test("Load profile when none exists")
    func testLoadProfileWhenNoneExists() throws {
        let service = UserDefaultsUserProfileService()
        
        let loadedProfile = try service.loadProfile()
        
        #expect(loadedProfile == nil)
    }
    
    @Test("Update existing profile")
    func testUpdateProfile() throws {
        let service = UserDefaultsUserProfileService()
        let originalProfile = UserProfile(
            name: "Original Name",
            gender: .boy,
            birthDate: Date(),
            interests: ["toys"],
            motherDueDate: nil
        )
        
        try service.saveProfile(originalProfile)
        
        let updatedProfile = UserProfile(
            id: originalProfile.id, // Same ID
            name: "Updated Name",
            gender: .girl,
            birthDate: originalProfile.dateOfBirth!,
            interests: ["books", "art"],
            motherDueDate: nil
        )
        
        try service.updateProfile(updatedProfile)
        let loadedProfile = try service.loadProfile()
        
        #expect(loadedProfile?.name == "Updated Name")
        #expect(loadedProfile?.gender == .girl)
        #expect(loadedProfile?.interests == ["books", "art"])
        #expect(loadedProfile?.id == originalProfile.id)
    }
    
    @Test("Delete profile")
    func testDeleteProfile() throws {
        let service = UserDefaultsUserProfileService()
        let profile = UserProfile(
            name: "To Delete",
            gender: .boy,
            birthDate: Date(),
            interests: ["temporary"],
            motherDueDate: nil
        )
        
        try service.saveProfile(profile)
        #expect(try service.loadProfile() != nil)
        
        try service.deleteProfile()
        #expect(try service.loadProfile() == nil)
    }
    
    @Test("Profile exists check")
    func testProfileExists() throws {
        let service = UserDefaultsUserProfileService()
        
        #expect(service.profileExists() == false)
        
        let profile = UserProfile(
            name: "Exists Test",
            gender: .girl,
            birthDate: Date(),
            interests: ["checking"],
            motherDueDate: nil
        )
        
        try service.saveProfile(profile)
        #expect(service.profileExists() == true)
        
        try service.deleteProfile()
        #expect(service.profileExists() == false)
    }
    
    @Test("Save profile with pregnancy data")
    func testSaveProfileWithPregnancy() throws {
        let service = UserDefaultsUserProfileService()
        let dueDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
        let profile = UserProfile(
            name: "Expecting Mother",
            babyStage: .pregnancy,
            interests: ["parenting"],
            storyTime: Date(),
            dueDate: dueDate,
            parentNames: ["Mom", "Dad"],
            dateOfBirth: nil,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: Language.deviceDefault
        )
        
        try service.saveProfile(profile)
        let loadedProfile = try service.loadProfile()
        
        #expect(loadedProfile?.isPregnancy == true)
        #expect(loadedProfile?.dueDate != nil)
        #expect(loadedProfile?.parentNames == ["Mom", "Dad"])
        #expect(loadedProfile?.dateOfBirth == nil)
    }
    
    @Test("Codable compliance with complex profile")
    func testCodableCompliance() throws {
        let service = UserDefaultsUserProfileService()
        let calendar = Calendar.current
        
        let profile = UserProfile(
            name: "Complex Profile",
            babyStage: .preschooler,
            interests: ["art", "music", "sports", "reading"],
            storyTime: calendar.date(from: DateComponents(hour: 19, minute: 30))!,
            dueDate: nil,
            parentNames: [],
            dateOfBirth: calendar.date(byAdding: .year, value: -4, to: Date()),
            lastUpdate: Date(),
            gender: .nonBinary,
            language: Language.vietnamese
        )
        
        try service.saveProfile(profile)
        let loadedProfile = try service.loadProfile()
        
        #expect(loadedProfile?.name == "Complex Profile")
        #expect(loadedProfile?.babyStage == .preschooler)
        #expect(loadedProfile?.interests.count == 4)
        #expect(loadedProfile?.gender == .nonBinary)
        #expect(loadedProfile?.language == Language.vietnamese)
        
        // Check that story time is preserved
        let savedStoryTime = loadedProfile?.storyTime
        let originalStoryTime = profile.storyTime
        #expect(Calendar.current.component(.hour, from: savedStoryTime!) == Calendar.current.component(.hour, from: originalStoryTime))
        #expect(Calendar.current.component(.minute, from: savedStoryTime!) == Calendar.current.component(.minute, from: originalStoryTime))
    }
    
    @Test("Error handling for corrupted data")
    func testErrorHandlingCorruptedData() {
        let service = UserDefaultsUserProfileService()
        
        // Manually set corrupted data
        UserDefaults.standard.set("corrupted data", forKey: "user_profile")
        
        #expect(throws: AppError.self) {
            try service.loadProfile()
        }
    }
    
    @Test("Multiple save and load operations")
    func testMultipleSaveAndLoadOperations() throws {
        let service = UserDefaultsUserProfileService()
        
        // Save first profile
        let profile1 = UserProfile(
            name: "First Child",
            gender: .boy,
            birthDate: Date(),
            interests: ["first"],
            motherDueDate: nil
        )
        try service.saveProfile(profile1)
        
        // Save second profile (should overwrite)
        let profile2 = UserProfile(
            name: "Second Child",
            gender: .girl,
            birthDate: Date(),
            interests: ["second"],
            motherDueDate: nil
        )
        try service.saveProfile(profile2)
        
        let loadedProfile = try service.loadProfile()
        
        #expect(loadedProfile?.name == "Second Child")
        #expect(loadedProfile?.gender == .girl)
        #expect(loadedProfile?.interests == ["second"])
    }
    
    @Test("Profile data integrity")
    func testProfileDataIntegrity() throws {
        let service = UserDefaultsUserProfileService()
        let calendar = Calendar.current
        
        let birthDate = calendar.date(byAdding: .year, value: -2, to: Date())!
        let storyTime = calendar.date(from: DateComponents(hour: 20, minute: 0))!
        
        let profile = UserProfile(
            name: "Integrity Test",
            babyStage: .toddler,
            interests: ["blocks", "books"],
            storyTime: storyTime,
            dueDate: nil,
            parentNames: [],
            dateOfBirth: birthDate,
            lastUpdate: Date(),
            gender: .boy,
            language: Language.english
        )
        
        try service.saveProfile(profile)
        let loadedProfile = try service.loadProfile()
        
        // Verify all data is preserved exactly
        #expect(loadedProfile?.name == profile.name)
        #expect(loadedProfile?.babyStage == profile.babyStage)
        #expect(loadedProfile?.interests == profile.interests)
        #expect(loadedProfile?.gender == profile.gender)
        #expect(loadedProfile?.language == profile.language)
        #expect(loadedProfile?.isPregnancy == profile.isPregnancy)
        
        // Verify computed properties work correctly
        #expect(loadedProfile?.displayName == profile.displayName)
        #expect(loadedProfile?.ageInMonths == profile.ageInMonths)
    }
}
