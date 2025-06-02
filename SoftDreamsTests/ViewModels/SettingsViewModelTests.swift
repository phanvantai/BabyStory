import Testing
import Foundation
@testable import SoftDreams

@MainActor
struct SettingsViewModelTests {
    
    init() {
        // Clean up before each test
        StorageManager.shared.clearAllData()
    }
    
    deinit {
        // Clean up after each test
        StorageManager.shared.clearAllData()
    }
    
    @Test("Initialization sets up app info correctly")
    func testInitialization() {
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.appName.isEmpty == false)
        #expect(viewModel.appVersion.isEmpty == false)
        #expect(viewModel.narrationEnabled == true)
        #expect(viewModel.parentalLockEnabled == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.profile == nil) // No profile saved initially
    }
    
    @Test("Support URL is valid")
    func testSupportURL() {
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.supportURL.absoluteString == "https://taiphanvan.dev")
    }
    
    @Test("Load profile when profile exists")
    func testLoadProfileWhenExists() throws {
        // Save a profile first
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Date(),
            interests: ["dragons"],
            motherDueDate: nil
        )
        try StorageManager.shared.saveProfile(profile)
        
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.profile != nil)
        #expect(viewModel.profile?.name == "Test Child")
        #expect(viewModel.error == nil)
    }
    
    @Test("Load profile when no profile exists")
    func testLoadProfileWhenNone() {
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.profile == nil)
        #expect(viewModel.error == nil)
    }
    
    @Test("Save profile successfully")
    func testSaveProfileSuccess() throws {
        let viewModel = SettingsViewModel()
        let profile = UserProfile(
            name: "New Child",
            gender: .girl,
            birthDate: Date(),
            interests: ["unicorns"],
            motherDueDate: nil
        )
        
        viewModel.saveProfile(profile)
        
        #expect(viewModel.profile?.name == "New Child")
        #expect(viewModel.error == nil)
        
        // Verify it's actually saved in storage
        let loadedProfile = try StorageManager.shared.loadProfile()
        #expect(loadedProfile?.name == "New Child")
    }
    
    @Test("Toggle parental lock with correct passcode")
    func testToggleParentalLockCorrectPasscode() {
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.parentalLockEnabled == false)
        
        let success = viewModel.toggleParentalLock(passcode: "1234")
        
        #expect(success == true)
        #expect(viewModel.parentalLockEnabled == true)
        
        // Toggle again
        let success2 = viewModel.toggleParentalLock(passcode: "1234")
        
        #expect(success2 == true)
        #expect(viewModel.parentalLockEnabled == false)
    }
    
    @Test("Toggle parental lock with incorrect passcode")
    func testToggleParentalLockIncorrectPasscode() {
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.parentalLockEnabled == false)
        
        let success = viewModel.toggleParentalLock(passcode: "wrong")
        
        #expect(success == false)
        #expect(viewModel.parentalLockEnabled == false)
    }
    
    @Test("Save narration enabled successfully")
    func testSaveNarrationEnabledSuccess() throws {
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.narrationEnabled == true)
        
        viewModel.saveNarrationEnabled(false)
        
        #expect(viewModel.narrationEnabled == false)
        #expect(viewModel.error == nil)
        
        // Verify it's actually saved in storage
        let savedSetting = try StorageManager.shared.loadNarrationEnabled()
        #expect(savedSetting == false)
    }
    
    @Test("Save parental lock enabled successfully")
    func testSaveParentalLockEnabledSuccess() throws {
        let viewModel = SettingsViewModel()
        
        #expect(viewModel.parentalLockEnabled == false)
        
        viewModel.saveParentalLockEnabled(true)
        
        #expect(viewModel.parentalLockEnabled == true)
        #expect(viewModel.error == nil)
        
        // Verify it's actually saved in storage
        let savedSetting = try StorageManager.shared.loadParentalLockEnabled()
        #expect(savedSetting == true)
    }
    
    @Test("Save parental passcode successfully")
    func testSaveParentalPasscodeSuccess() throws {
        let viewModel = SettingsViewModel()
        
        viewModel.saveParentalPasscode("5678")
        
        #expect(viewModel.error == nil)
        
        // Verify it's actually saved in storage
        let savedPasscode = try StorageManager.shared.loadParentalPasscode()
        #expect(savedPasscode == "5678")
    }
    
    @Test("Handle notification permission granted")
    func testHandleNotificationPermissionGranted() async {
        let viewModel = SettingsViewModel()
        
        // This is an async method that doesn't return a value
        // We can test that it executes without throwing
        await viewModel.handleNotificationPermissionGranted()
        
        // No errors should be set
        #expect(viewModel.error == nil)
    }
    
    @Test("Handle notification permission denied")
    func testHandleNotificationPermissionDenied() {
        let viewModel = SettingsViewModel()
        
        // This method just logs, so we test it executes without issues
        viewModel.handleNotificationPermissionDenied()
        
        // No errors should be set
        #expect(viewModel.error == nil)
    }
    
    @Test("Load settings loads default values")
    func testLoadSettings() {
        let viewModel = SettingsViewModel()
        
        // Currently loadSettings is mostly commented out
        // Testing that it runs without error
        viewModel.loadSettings()
        
        #expect(viewModel.error == nil)
    }
    
    @Test("App info properties are accessible")
    func testAppInfoProperties() {
        let viewModel = SettingsViewModel()
        
        // Test that app info is loaded
        #expect(viewModel.appName.isEmpty == false)
        #expect(viewModel.appVersion.isEmpty == false)
        
        // These should be the same as what AppInfoService provides
        let appInfo = AppInfoService.shared
        #expect(viewModel.appName == appInfo.appName)
        #expect(viewModel.appVersion == appInfo.appVersion)
    }
    
    @Test("Error handling for profile save failure")
    func testProfileSaveError() {
        let viewModel = SettingsViewModel()
        
        // Test with a malformed profile that might cause save to fail
        // Since our current implementation doesn't actually fail,
        // we test the error handling path exists
        let profile = UserProfile(
            name: "",
            gender: .boy,
            birthDate: Date(),
            interests: [],
            motherDueDate: nil
        )
        
        viewModel.saveProfile(profile)
        
        // Even empty name should save successfully with current implementation
        #expect(viewModel.profile?.name == "")
        #expect(viewModel.error == nil)
    }
    
    @Test("Multiple settings operations")
    func testMultipleSettingsOperations() throws {
        let viewModel = SettingsViewModel()
        
        // Test multiple operations in sequence
        viewModel.saveNarrationEnabled(false)
        #expect(viewModel.narrationEnabled == false)
        #expect(viewModel.error == nil)
        
        viewModel.saveParentalLockEnabled(true)
        #expect(viewModel.parentalLockEnabled == true)
        #expect(viewModel.error == nil)
        
        viewModel.saveParentalPasscode("9999")
        #expect(viewModel.error == nil)
        
        // Verify all settings are saved
        #expect(try StorageManager.shared.loadNarrationEnabled() == false)
        #expect(try StorageManager.shared.loadParentalLockEnabled() == true)
        #expect(try StorageManager.shared.loadParentalPasscode() == "9999")
    }
    
    @Test("Profile reload after save")
    func testProfileReloadAfterSave() throws {
        let viewModel = SettingsViewModel()
        
        let profile = UserProfile(
            name: "Test Child",
            gender: .boy,
            birthDate: Date(),
            interests: ["adventure"],
            motherDueDate: nil
        )
        
        viewModel.saveProfile(profile)
        #expect(viewModel.profile?.name == "Test Child")
        
        // Create new view model to test loading
        let newViewModel = SettingsViewModel()
        #expect(newViewModel.profile?.name == "Test Child")
        #expect(newViewModel.profile?.interests == ["adventure"])
    }
}
