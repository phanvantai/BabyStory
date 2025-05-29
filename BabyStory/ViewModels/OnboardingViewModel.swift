import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var age: Int = 3
    @Published var interests: [String] = []
    @Published var storyTime: Date = Date()
    @Published var step: Int = 0
    
    func saveProfile() {
        let profile = UserProfile(name: name, age: age, interests: interests, storyTime: storyTime)
        UserDefaultsManager.shared.saveProfile(profile)
    }
}
