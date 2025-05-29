import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var age: Int? = nil
    @Published var babyStage: BabyStage = .toddler
    @Published var interests: [String] = []
    @Published var storyTime: Date = Date()
    @Published var dueDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @Published var parentNames: [String] = []
    @Published var step: Int = 0
    
    init() {
        // Initialize with default values based on the default baby stage
        initializeForCurrentBabyStage()
    }
    
    // Initialization helper method
    private func initializeForCurrentBabyStage() {
        // Initialize parent names if pregnancy and empty
        if isPregnancy && parentNames.isEmpty {
            addParentName()
        }
        
        // Initialize age based on baby stage if it's nil
        if age == nil {
            switch babyStage {
            case .toddler:
                age = 1  // Default toddler age
            case .preschooler:
                age = 3  // Default preschooler age
            case .newborn, .infant:
                age = 0  // Fixed at 0 for newborn and infant
            case .pregnancy:
                break  // No age for pregnancy
            }
        }
    }
    
    // Computed properties for UI state
    var isPregnancy: Bool {
        return babyStage == .pregnancy
    }
    
    var shouldShowAge: Bool {
        return !isPregnancy
    }
    
    var shouldShowDueDate: Bool {
        return isPregnancy
    }
    
    var shouldShowParentNames: Bool {
        return isPregnancy
    }
    
    // Age control properties
    var canEditAge: Bool {
        return babyStage == .toddler || babyStage == .preschooler
    }
    
    var ageRange: ClosedRange<Int> {
        switch babyStage {
        case .newborn, .infant:
            return 0...0  // Fixed at 0
        case .toddler:
            return 1...3
        case .preschooler:
            return 3...5
        case .pregnancy:
            return 0...0  // Not applicable
        }
    }
    
    var ageDisplayText: String {
        guard let age = age else { return "Not set" }
        
        switch babyStage {
        case .newborn:
            return "Newborn (0-3 months)"
        case .infant:
            return "Infant (3-12 months)"
        case .toddler:
            return "\(age) year\(age == 1 ? "" : "s") old"
        case .preschooler:
            return "\(age) years old"
        case .pregnancy:
            return "Not applicable"
        }
    }
    
    // Available interests based on baby stage
    var availableInterests: [String] {
        switch babyStage {
        case .pregnancy:
            return [
                "Classical Music",
                "Nature Sounds",
                "Gentle Stories",
                "Parent Bonding",
                "Relaxation",
                "Love & Care"
            ]
        case .newborn:
            return [
                "Lullabies",
                "Gentle Sounds",
                "Soft Colors",
                "Comfort",
                "Sleep",
                "Feeding Time"
            ]
        case .infant:
            return [
                "Peek-a-boo",
                "Simple Sounds",
                "Textures",
                "Movement",
                "Smiles",
                "Discovery"
            ]
        case .toddler:
            return [
                "Animals",
                "Colors",
                "Numbers",
                "Vehicles",
                "Nature",
                "Family",
                "Friends",
                "Playing"
            ]
        case .preschooler:
            return [
                "Adventure",
                "Magic",
                "Friendship",
                "Learning",
                "Imagination",
                "Problem Solving",
                "Emotions",
                "School"
            ]
        }
    }
    
    // Validation methods
    var isValidName: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isValidAge: Bool {
        if isPregnancy {
            return true // Age not required for pregnancy
        }
        return age != nil && age! >= 0 && age! <= 10
    }
    
    var isValidParentNames: Bool {
        if !isPregnancy {
            return true // Parent names not required for born babies
        }
        return !parentNames.isEmpty && parentNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    var canProceed: Bool {
        return isValidName && isValidAge && isValidParentNames
    }
    
    // Helper methods
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
    
    func updateBabyStage(_ newStage: BabyStage) {
        babyStage = newStage
        
        // Clear age if switching to pregnancy
        if newStage == .pregnancy {
            age = nil
            if parentNames.isEmpty {
                parentNames = [""] // Start with one empty parent name
            }
        } else {
            // Set fixed or default age based on stage
            switch newStage {
            case .newborn, .infant:
                age = 0  // Fixed at 0 for both newborn and infant
            case .toddler:
                age = max(1, min(age ?? 1, 3))  // Clamp existing age to 1-3, default to 1
            case .preschooler:
                age = max(3, min(age ?? 3, 5))  // Clamp existing age to 3-5, default to 3
            case .pregnancy:
                break
            }
            parentNames.removeAll()
        }
        
        // Clear interests when stage changes
        interests.removeAll()
    }
    
    // Age adjustment methods with range validation
    func increaseAge() {
        guard canEditAge, let currentAge = age else { return }
        let maxAge = ageRange.upperBound
        if currentAge < maxAge {
            age = currentAge + 1
        }
    }
    
    func decreaseAge() {
        guard canEditAge, let currentAge = age else { return }
        let minAge = ageRange.lowerBound
        if currentAge > minAge {
            age = currentAge - 1
        }
    }
    
    func toggleInterest(_ interest: String) {
        if interests.contains(interest) {
            interests.removeAll { $0 == interest }
        } else {
            interests.append(interest)
        }
    }
    
    func saveProfile() {
        let profile = UserProfile(
            name: name,
            age: age,
            babyStage: babyStage,
            interests: interests,
            storyTime: storyTime,
            dueDate: isPregnancy ? dueDate : nil,
            parentNames: isPregnancy ? parentNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } : []
        )
        UserDefaultsManager.shared.saveProfile(profile)
    }
}
