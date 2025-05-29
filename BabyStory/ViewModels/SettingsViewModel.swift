import Foundation

class SettingsViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var narrationEnabled: Bool = true
    @Published var parentalLockEnabled: Bool = false
    private let parentalPasscode = "1234" // Dummy passcode
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        profile = UserDefaultsManager.shared.loadProfile()
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
}
