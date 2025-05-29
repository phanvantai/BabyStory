import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var narrationEnabled: Bool = true
    @Published var parentalLockEnabled: Bool = false
    private let parentalPasscode = "1234" // Dummy passcode
    
    // Support URL - can be updated later
    let supportURL = URL(string: "https://taiphanvan.dev")!
    
    init() {
        loadProfile()
        loadSettings()
    }
    
    func loadProfile() {
        profile = UserDefaultsManager.shared.loadProfile()
    }
    
    func loadSettings() {
        // Load other settings here if needed
    }
    
    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        UserDefaultsManager.shared.saveProfile(profile)
    }
    
    func toggleParentalLock(passcode: String) -> Bool {
        if passcode == parentalPasscode {
            parentalLockEnabled.toggle()
            return true
        }
        return false
    }
    
    // Open URL in default browser
    func openSupportWebsite() {
        if UIApplication.shared.canOpenURL(supportURL) {
            UIApplication.shared.open(supportURL)
        }
    }
}
