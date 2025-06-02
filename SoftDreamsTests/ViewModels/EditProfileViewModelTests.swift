import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct EditProfileViewModelTests {
    
    init() {
        // Clean up before each test
        StorageManager.shared.clearAllData()
    }
    
    deinit {
        // Clean up after each test
        StorageManager.shared.clearAllData()
    }
    
    @Test("Initialization with no existing profile")
    func testInitializationNoProfile() {
        let viewModel = EditProfileViewModel()
        
        #expect(viewModel.name == "")
        #expect(viewModel.babyStage == .toddler)
        #expect(viewModel.gender == .notSpecified)
        #expect(viewModel.interests.isEmpty)
        #expect(viewModel.parentNames.isEmpty)
        #expect(viewModel.dateOfBirth == nil)
        #expect(viewModel.language == Language.deviceDefault)
        #expect(viewModel.error == .invalidProfile) // No profile to edit
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showTimePicker == false)
    }
    
    @Test("Initialization with existing profile")
    func testInitializationWithProfile() throws {
        // Save a profile first
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
            interests: ["dragons", "adventure"],
            motherDueDate: nil
        )
        try StorageManager.shared.saveProfile(profile)
        
        let viewModel = EditProfileViewModel()
        
        #expect(viewModel.name == "Test Child")
        #expect(viewModel.gender == .boy)
        #expect(viewModel.interests == ["dragons", "adventure"])
        #expect(viewModel.dateOfBirth != nil)
        #expect(viewModel.error == nil)
    }
    
    @Test("Computed property isPregnancy")
    func testIsPregnancy() {
        let viewModel = EditProfileViewModel()
        
        viewModel.babyStage = .pregnancy
        #expect(viewModel.isPregnancy == true)
        
        viewModel.babyStage = .newborn
        #expect(viewModel.isPregnancy == false)
        
        viewModel.babyStage = .toddler
        #expect(viewModel.isPregnancy == false)
    }
    
    @Test("Computed property shouldShowDateOfBirth")
    func testShouldShowDateOfBirth() {
        let viewModel = EditProfileViewModel()
        
        viewModel.babyStage = .pregnancy
        #expect(viewModel.shouldShowDateOfBirth == false)
        
        viewModel.babyStage = .newborn
        #expect(viewModel.shouldShowDateOfBirth == true)
        
        viewModel.babyStage = .toddler
        #expect(viewModel.shouldShowDateOfBirth == true)
    }
    
    @Test("Computed property shouldShowDueDate")
    func testShouldShowDueDate() {
        let viewModel = EditProfileViewModel()
        
        viewModel.babyStage = .pregnancy
        #expect(viewModel.shouldShowDueDate == true)
        
        viewModel.babyStage = .newborn
        #expect(viewModel.shouldShowDueDate == false)
    }
    
    @Test("Computed property shouldShowParentNames")
    func testShouldShowParentNames() {
        let viewModel = EditProfileViewModel()
        
        viewModel.babyStage = .pregnancy
        #expect(viewModel.shouldShowParentNames == true)
        
        viewModel.babyStage = .infant
        #expect(viewModel.shouldShowParentNames == false)
    }
    
    @Test("Date of birth range")
    func testDateOfBirthRange() {
        let viewModel = EditProfileViewModel()
        let range = viewModel.dateOfBirthRange
        let calendar = Calendar.current
        
        // Check that max date is today
        #expect(calendar.isDate(range.upperBound, inSameDayAs: Date()))
        
        // Check that min date is approximately 6 years ago
        let sixYearsAgo = calendar.date(byAdding: .year, value: -6, to: Date())!
        #expect(calendar.isDate(range.lowerBound, inSameDayAs: sixYearsAgo))
    }
    
    @Test("Age display text with no date of birth")
    func testAgeDisplayTextNoDate() {
        let viewModel = EditProfileViewModel()
        viewModel.dateOfBirth = nil
        
        #expect(viewModel.ageDisplayText == "edit_profile_age_not_set".localized)
    }
    
    @Test("Age display text with months")
    func testAgeDisplayTextMonths() {
        let viewModel = EditProfileViewModel()
        let calendar = Calendar.current
        
        // 6 months old
        viewModel.dateOfBirth = calendar.date(byAdding: .month, value: -6, to: Date())
        
        let ageText = viewModel.ageDisplayText
        #expect(ageText.contains("6") || ageText.contains("month"))
    }
    
    @Test("Age display text with years")
    func testAgeDisplayTextYears() {
        let viewModel = EditProfileViewModel()
        let calendar = Calendar.current
        
        // 3 years old
        viewModel.dateOfBirth = calendar.date(byAdding: .year, value: -3, to: Date())
        
        let ageText = viewModel.ageDisplayText
        #expect(ageText.contains("3") || ageText.contains("year"))
    }
    
    @Test("Available interests based on baby stage")
    func testAvailableInterests() {
        let viewModel = EditProfileViewModel()
        
        viewModel.babyStage = .newborn
        let newbornInterests = viewModel.availableInterests
        #expect(newbornInterests.isEmpty == false)
        
        viewModel.babyStage = .toddler
        let toddlerInterests = viewModel.availableInterests
        #expect(toddlerInterests.isEmpty == false)
        
        // Different stages should potentially have different interests
        // (depends on implementation in BabyStage extension)
    }
    
    @Test("Name validation")
    func testNameValidation() {
        let viewModel = EditProfileViewModel()
        
        viewModel.name = ""
        #expect(viewModel.isValidName == false)
        
        viewModel.name = "   "
        #expect(viewModel.isValidName == false)
        
        viewModel.name = "Valid Name"
        #expect(viewModel.isValidName == true)
    }
    
    @Test("Date of birth validation")
    func testDateOfBirthValidation() {
        let viewModel = EditProfileViewModel()
        
        // For pregnancy, date of birth not required
        viewModel.babyStage = .pregnancy
        viewModel.dateOfBirth = nil
        #expect(viewModel.isValidDateOfBirth == true)
        
        // For born babies, date of birth required
        viewModel.babyStage = .toddler
        viewModel.dateOfBirth = nil
        #expect(viewModel.isValidDateOfBirth == false)
        
        viewModel.dateOfBirth = Date()
        #expect(viewModel.isValidDateOfBirth == true)
    }
    
    @Test("Parent names validation")
    func testParentNamesValidation() {
        let viewModel = EditProfileViewModel()
        
        // For born babies, parent names not required
        viewModel.babyStage = .toddler
        viewModel.parentNames = []
        #expect(viewModel.isValidParentNames == true)
        
        // For pregnancy, parent names required
        viewModel.babyStage = .pregnancy
        viewModel.parentNames = []
        #expect(viewModel.isValidParentNames == false)
        
        viewModel.parentNames = [""]
        #expect(viewModel.isValidParentNames == false)
        
        viewModel.parentNames = ["   "]
        #expect(viewModel.isValidParentNames == false)
        
        viewModel.parentNames = ["Mom"]
        #expect(viewModel.isValidParentNames == true)
        
        viewModel.parentNames = ["Mom", "Dad"]
        #expect(viewModel.isValidParentNames == true)
    }
    
    @Test("Can save validation")
    func testCanSave() {
        let viewModel = EditProfileViewModel()
        
        // Invalid name should prevent saving
        viewModel.name = ""
        #expect(viewModel.canSave == false)
        
        // Valid setup for toddler
        viewModel.name = "Test Child"
        viewModel.babyStage = .toddler
        viewModel.dateOfBirth = Date()
        viewModel.isLoading = false
        #expect(viewModel.canSave == true)
        
        // Loading should prevent saving
        viewModel.isLoading = true
        #expect(viewModel.canSave == false)
    }
    
    @Test("Update baby stage to pregnancy")
    func testUpdateBabyStageToPregnancy() {
        let viewModel = EditProfileViewModel()
        
        viewModel.dateOfBirth = Date()
        viewModel.interests = ["toys"]
        
        viewModel.updateBabyStage(.pregnancy)
        
        #expect(viewModel.babyStage == .pregnancy)
        #expect(viewModel.dateOfBirth == nil)
        #expect(viewModel.parentNames.count == 1)
        #expect(viewModel.interests.isEmpty)
    }
    
    @Test("Update baby stage from pregnancy to born")
    func testUpdateBabyStageFromPregnancy() {
        let viewModel = EditProfileViewModel()
        
        viewModel.babyStage = .pregnancy
        viewModel.parentNames = ["Mom", "Dad"]
        viewModel.interests = []
        
        viewModel.updateBabyStage(.toddler)
        
        #expect(viewModel.babyStage == .toddler)
        #expect(viewModel.dateOfBirth != nil) // Should set default
        #expect(viewModel.parentNames.isEmpty)
        #expect(viewModel.interests.isEmpty)
    }
    
    @Test("Default date of birth setting")
    func testDefaultDateOfBirthSetting() {
        let viewModel = EditProfileViewModel()
        let calendar = Calendar.current
        
        // Test newborn default
        viewModel.updateBabyStage(.newborn)
        if let dob = viewModel.dateOfBirth {
            let monthsOld = calendar.dateComponents([.month], from: dob, to: Date()).month ?? 0
            #expect(monthsOld >= 0 && monthsOld <= 2) // Around 1 month old
        }
        
        // Test toddler default
        viewModel.dateOfBirth = nil
        viewModel.updateBabyStage(.toddler)
        if let dob = viewModel.dateOfBirth {
            let yearsOld = calendar.dateComponents([.year], from: dob, to: Date()).year ?? 0
            #expect(yearsOld >= 1 && yearsOld <= 3) // Around 2 years old
        }
    }
    
    @Test("Add parent name")
    func testAddParentName() {
        let viewModel = EditProfileViewModel()
        
        #expect(viewModel.parentNames.isEmpty)
        
        viewModel.addParentName()
        #expect(viewModel.parentNames.count == 1)
        #expect(viewModel.parentNames[0] == "")
        
        viewModel.addParentName()
        #expect(viewModel.parentNames.count == 2)
        
        // Should not add more than 2
        viewModel.addParentName()
        #expect(viewModel.parentNames.count == 2)
    }
    
    @Test("Remove parent name")
    func testRemoveParentName() {
        let viewModel = EditProfileViewModel()
        
        viewModel.parentNames = ["Mom", "Dad"]
        
        viewModel.removeParentName(at: 0)
        #expect(viewModel.parentNames.count == 1)
        #expect(viewModel.parentNames[0] == "Dad")
        
        viewModel.removeParentName(at: 0)
        #expect(viewModel.parentNames.isEmpty)
        
        // Should not crash with invalid index
        viewModel.removeParentName(at: 5)
        #expect(viewModel.parentNames.isEmpty)
    }
    
    @Test("Toggle interest")
    func testToggleInterest() {
        let viewModel = EditProfileViewModel()
        
        #expect(viewModel.interests.isEmpty)
        
        viewModel.toggleInterest("dragons")
        #expect(viewModel.interests.contains("dragons"))
        #expect(viewModel.interests.count == 1)
        
        viewModel.toggleInterest("unicorns")
        #expect(viewModel.interests.contains("unicorns"))
        #expect(viewModel.interests.count == 2)
        
        // Toggle off
        viewModel.toggleInterest("dragons")
        #expect(!viewModel.interests.contains("dragons"))
        #expect(viewModel.interests.count == 1)
    }
    
    @Test("Save profile successfully")
    func testSaveProfileSuccess() async throws {
        // Save initial profile
        let profile = UserProfile(
            name: "Original Name",
            gender: .boy,
            birthDate: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
            interests: ["toys"],
            motherDueDate: nil
        )
        try StorageManager.shared.saveProfile(profile)
        
        let viewModel = EditProfileViewModel()
        
        // Modify profile
        viewModel.name = "Updated Name"
        viewModel.gender = .girl
        viewModel.interests = ["dolls", "books"]
        
        let success = await viewModel.saveProfile()
        
        #expect(success == true)
        #expect(viewModel.error == nil)
        #expect(viewModel.isLoading == false)
        
        // Verify profile was actually saved
        let savedProfile = try StorageManager.shared.loadProfile()
        #expect(savedProfile?.name == "Updated Name")
        #expect(savedProfile?.gender == .girl)
        #expect(savedProfile?.interests == ["dolls", "books"])
    }
    
    @Test("Save profile with invalid data")
    func testSaveProfileInvalid() async {
        let viewModel = EditProfileViewModel()
        
        viewModel.name = "" // Invalid
        viewModel.babyStage = .toddler
        viewModel.dateOfBirth = nil // Invalid for non-pregnancy
        
        let success = await viewModel.saveProfile()
        
        #expect(success == false)
        #expect(viewModel.error == .invalidProfile)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Has changes detection")
    func testHasChanges() throws {
        // Save initial profile
        let profile = UserProfile(
            name: "Test Name",
            gender: .boy,
            birthDate: Date(),
            interests: ["toys"],
            motherDueDate: nil
        )
        try StorageManager.shared.saveProfile(profile)
        
        let viewModel = EditProfileViewModel()
        
        // Initially no changes
        #expect(viewModel.hasChanges == false)
        
        // Make a change
        viewModel.name = "Different Name"
        #expect(viewModel.hasChanges == true)
        
        // Revert change
        viewModel.name = "Test Name"
        #expect(viewModel.hasChanges == false)
        
        // Change interests
        viewModel.interests = ["books"]
        #expect(viewModel.hasChanges == true)
    }
    
    @Test("Cancel editing")
    func testCancelEditing() throws {
        // Save initial profile
        let profile = UserProfile(
            name: "Original Name",
            gender: .boy,
            birthDate: Date(),
            interests: ["toys"],
            motherDueDate: nil
        )
        try StorageManager.shared.saveProfile(profile)
        
        let viewModel = EditProfileViewModel()
        
        // Make changes
        viewModel.name = "Changed Name"
        viewModel.gender = .girl
        viewModel.interests = ["books"]
        
        #expect(viewModel.hasChanges == true)
        
        // Cancel editing
        viewModel.cancelEditing()
        
        #expect(viewModel.name == "Original Name")
        #expect(viewModel.gender == .boy)
        #expect(viewModel.interests == ["toys"])
        #expect(viewModel.error == nil)
        #expect(viewModel.hasChanges == false)
    }
    
    @Test("Language change during save")
    func testLanguageChangeDuringSave() async throws {
        // Save initial profile with English
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Date(),
            interests: ["toys"],
            motherDueDate: nil
        )
        try StorageManager.shared.saveProfile(profile)
        
        let viewModel = EditProfileViewModel()
        
        // Change language to Vietnamese
        viewModel.language = Language.vietnamese
        
        let success = await viewModel.saveProfile()
        
        #expect(success == true)
        #expect(viewModel.error == nil)
        
        // Verify language was updated
        let savedProfile = try StorageManager.shared.loadProfile()
        #expect(savedProfile?.language == Language.vietnamese)
    }
    
    @Test("Profile update notifications handling")
    func testProfileUpdateNotifications() async throws {
        // Test pregnancy to born baby transition
        let pregnancyProfile = UserProfile(
            name: "Test Mother",
            babyStage: .pregnancy,
            interests: [],
            storyTime: Date(),
            dueDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
            parentNames: ["Mom"],
            dateOfBirth: nil,
            lastUpdate: Date(),
            gender: .notSpecified,
            language: Language.deviceDefault
        )
        try StorageManager.shared.saveProfile(pregnancyProfile)
        
        let viewModel = EditProfileViewModel()
        
        // Change to born baby
        viewModel.updateBabyStage(.newborn)
        viewModel.dateOfBirth = Date()
        
        let success = await viewModel.saveProfile()
        
        #expect(success == true)
        #expect(viewModel.error == nil)
        
        // Verify profile was updated
        let savedProfile = try StorageManager.shared.loadProfile()
        #expect(savedProfile?.babyStage == .newborn)
        #expect(savedProfile?.isPregnancy == false)
    }
}
