import Foundation

enum BabyStage: String, Codable, CaseIterable {
    case pregnancy = "pregnancy"
    case newborn = "newborn"
    case infant = "infant"
    case toddler = "toddler"
    case preschooler = "preschooler"
    
    var displayName: String {
        switch self {
        case .pregnancy:
            return "During Pregnancy"
        case .newborn:
            return "Newborn (0-3 months)"
        case .infant:
            return "Infant (3-12 months)"
        case .toddler:
            return "Toddler (1-3 years)"
        case .preschooler:
            return "Preschooler (3-5 years)"
        }
    }
    
    var description: String {
        switch self {
        case .pregnancy:
            return "Create bonding stories for your unborn baby"
        case .newborn:
            return "Gentle, soothing stories for newborns"
        case .infant:
            return "Simple stories with sounds and textures"
        case .toddler:
            return "Interactive stories with basic lessons"
        case .preschooler:
            return "Adventure stories with moral lessons"
        }
    }
}

struct UserProfile: Codable, Equatable {
    var name: String
    var age: Int? // Optional for pregnancy stage
    var babyStage: BabyStage
    var interests: [String]
    var storyTime: Date
    var dueDate: Date? // For pregnancy stage
    var parentNames: [String] // For pregnancy stories
    
    // Computed property to determine if this is for an unborn baby
    var isPregnancy: Bool {
        return babyStage == .pregnancy
    }
    
    // Computed property for display name
    var displayName: String {
        if isPregnancy {
            return "Baby \(name)"
        } else {
            return name
        }
    }
    
    // Computed property for story context
    var storyContext: String {
        switch babyStage {
        case .pregnancy:
            let parentNamesString = parentNames.isEmpty ? "Mommy and Daddy" : parentNames.joined(separator: " and ")
            return "A story for baby \(name) from \(parentNamesString)"
        case .newborn, .infant:
            return "A gentle story for little \(name)"
        case .toddler, .preschooler:
            return "An adventure story for \(name)"
        }
    }
    
    // Initialize with default values for pregnancy
    init(name: String, age: Int? = nil, babyStage: BabyStage = .toddler, interests: [String] = [], storyTime: Date = Date(), dueDate: Date? = nil, parentNames: [String] = []) {
        self.name = name
        self.age = age
        self.babyStage = babyStage
        self.interests = interests
        self.storyTime = storyTime
        self.dueDate = dueDate
        self.parentNames = parentNames
    }
}

// MARK: - UserProfile Extensions
extension UserProfile {
    /// Generates a contextual welcome subtitle based on the current time and baby stage
    func getWelcomeSubtitle() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        
        switch hour {
        case 6..<12:
            greeting = "Good morning!"
        case 12..<17:
            greeting = "Good afternoon!"
        case 17..<21:
            greeting = "Good evening!"
        default:
            greeting = "Sweet dreams!"
        }
        
        switch babyStage {
        case .pregnancy:
            return "\(greeting) Ready for a bonding story?"
        case .newborn, .infant:
            return "\(greeting) Time for a gentle story?"
        case .toddler:
            return "\(greeting) Ready for an adventure?"
        case .preschooler:
            return "\(greeting) What story shall we explore?"
        }
    }
}
