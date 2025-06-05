//
//  PredefinedCharacters.swift
//  SoftDreams
//
//  Created by Copilot on 6/5/25.
//

import Foundation

// MARK: - PredefinedCharacter Model
struct PredefinedCharacter {
    let name: String
    let appropriateAges: Set<BabyStage>
}

// MARK: - PredefinedCharacters Service
struct PredefinedCharacters {
    
    // MARK: - Predefined Characters Collection
    static let allCharacters: [PredefinedCharacter] = [
        // Universal characters (all ages)
        PredefinedCharacter(
            name: "Luna the Moon Bear",
            appropriateAges: [.pregnancy, .newborn, .infant, .toddler, .preschooler]
        ),
        PredefinedCharacter(
            name: "Sunny the Golden Butterfly",
            appropriateAges: [.pregnancy, .newborn, .infant, .toddler, .preschooler]
        ),
        
        // Early stage characters (pregnancy, newborn, infant)
        PredefinedCharacter(
            name: "Gentle the Cloud Bunny",
            appropriateAges: [.pregnancy, .newborn, .infant]
        ),
        PredefinedCharacter(
            name: "Whisper the Wind Fairy",
            appropriateAges: [.pregnancy, .newborn, .infant]
        ),
        
        // Infant and toddler characters
        PredefinedCharacter(
            name: "Giggles the Rainbow Puppy",
            appropriateAges: [.infant, .toddler, .preschooler]
        ),
        PredefinedCharacter(
            name: "Bounce the Happy Frog",
            appropriateAges: [.infant, .toddler, .preschooler]
        ),
        
        // Toddler and preschooler characters
        PredefinedCharacter(
            name: "Adventure the Brave Lion",
            appropriateAges: [.toddler, .preschooler]
        ),
        PredefinedCharacter(
            name: "Wonder the Wise Owl",
            appropriateAges: [.toddler, .preschooler]
        ),
        PredefinedCharacter(
            name: "Magic the Sparkle Dragon",
            appropriateAges: [.toddler, .preschooler]
        ),
        
        // Preschooler specific character
        PredefinedCharacter(
            name: "Explorer the Curious Fox",
            appropriateAges: [.preschooler]
        )
    ]
    
    // MARK: - Random Character Selection
    
    /// Returns a random selection of character names
    /// - Parameter count: Number of characters to return (0-10)
    /// - Returns: Array of character names, limited to available characters
    static func getRandomCharacters(count: Int) -> [String] {
        guard count > 0 else { return [] }
        
        let limitedCount = min(count, allCharacters.count)
        let shuffledCharacters = allCharacters.shuffled()
        
        return Array(shuffledCharacters.prefix(limitedCount)).map { $0.name }
    }
    
    // MARK: - Age-Appropriate Character Selection
    
    /// Returns age-appropriate characters for a specific baby stage
    /// - Parameters:
    ///   - babyStage: The baby's current stage
    ///   - count: Maximum number of characters to return
    /// - Returns: Array of character names appropriate for the given stage
    static func getAgeAppropriateCharacters(for babyStage: BabyStage, count: Int) -> [String] {
        guard count > 0 else { return [] }
        
        let appropriateCharacters = allCharacters.filter { character in
            character.appropriateAges.contains(babyStage)
        }
        
        let limitedCount = min(count, appropriateCharacters.count)
        let shuffledCharacters = appropriateCharacters.shuffled()
        
        return Array(shuffledCharacters.prefix(limitedCount)).map { $0.name }
    }
}
