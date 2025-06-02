//
//  BabyStageTests.swift
//  SoftDreamsTests
//
//  Created by AI Assistant on 2/6/25.
//

import XCTest
@testable import SoftDreams

final class BabyStageTests: XCTestCase {
    
    func testBabyStageRawValues() {
        // Test all raw values are correct
        XCTAssertEqual(BabyStage.pregnancy.rawValue, "pregnancy")
        XCTAssertEqual(BabyStage.newborn.rawValue, "newborn")
        XCTAssertEqual(BabyStage.infant.rawValue, "infant")
        XCTAssertEqual(BabyStage.toddler.rawValue, "toddler")
        XCTAssertEqual(BabyStage.preschooler.rawValue, "preschooler")
    }
    
    func testBabyStageDisplayNames() {
        // Test all display names return localized strings
        XCTAssertNotNil(BabyStage.pregnancy.displayName)
        XCTAssertNotNil(BabyStage.newborn.displayName)
        XCTAssertNotNil(BabyStage.infant.displayName)
        XCTAssertNotNil(BabyStage.toddler.displayName)
        XCTAssertNotNil(BabyStage.preschooler.displayName)
        
        // Ensure display names are not empty
        XCTAssertFalse(BabyStage.pregnancy.displayName.isEmpty)
        XCTAssertFalse(BabyStage.newborn.displayName.isEmpty)
        XCTAssertFalse(BabyStage.infant.displayName.isEmpty)
        XCTAssertFalse(BabyStage.toddler.displayName.isEmpty)
        XCTAssertFalse(BabyStage.preschooler.displayName.isEmpty)
    }
    
    func testBabyStageDescriptions() {
        // Test all descriptions return localized strings
        XCTAssertNotNil(BabyStage.pregnancy.description)
        XCTAssertNotNil(BabyStage.newborn.description)
        XCTAssertNotNil(BabyStage.infant.description)
        XCTAssertNotNil(BabyStage.toddler.description)
        XCTAssertNotNil(BabyStage.preschooler.description)
        
        // Ensure descriptions are not empty
        XCTAssertFalse(BabyStage.pregnancy.description.isEmpty)
        XCTAssertFalse(BabyStage.newborn.description.isEmpty)
        XCTAssertFalse(BabyStage.infant.description.isEmpty)
        XCTAssertFalse(BabyStage.toddler.description.isEmpty)
        XCTAssertFalse(BabyStage.preschooler.description.isEmpty)
    }
    
    func testBabyStageAvailableInterests() {
        // Test pregnancy interests
        let pregnancyInterests = BabyStage.pregnancy.availableInterests
        XCTAssertEqual(pregnancyInterests.count, 6)
        XCTAssertTrue(pregnancyInterests.allSatisfy { !$0.isEmpty })
        
        // Test newborn interests
        let newbornInterests = BabyStage.newborn.availableInterests
        XCTAssertEqual(newbornInterests.count, 7)
        XCTAssertTrue(newbornInterests.allSatisfy { !$0.isEmpty })
        
        // Test infant interests
        let infantInterests = BabyStage.infant.availableInterests
        XCTAssertEqual(infantInterests.count, 8)
        XCTAssertTrue(infantInterests.allSatisfy { !$0.isEmpty })
        
        // Test toddler interests
        let toddlerInterests = BabyStage.toddler.availableInterests
        XCTAssertEqual(toddlerInterests.count, 10)
        XCTAssertTrue(toddlerInterests.allSatisfy { !$0.isEmpty })
        
        // Test preschooler interests
        let preschoolerInterests = BabyStage.preschooler.availableInterests
        XCTAssertEqual(preschoolerInterests.count, 10)
        XCTAssertTrue(preschoolerInterests.allSatisfy { !$0.isEmpty })
    }
    
    func testBabyStageInterestsUniqueness() {
        // Test that each stage has unique interests (no duplicates within stage)
        let pregnancyInterests = BabyStage.pregnancy.availableInterests
        XCTAssertEqual(pregnancyInterests.count, Set(pregnancyInterests).count)
        
        let newbornInterests = BabyStage.newborn.availableInterests
        XCTAssertEqual(newbornInterests.count, Set(newbornInterests).count)
        
        let infantInterests = BabyStage.infant.availableInterests
        XCTAssertEqual(infantInterests.count, Set(infantInterests).count)
        
        let toddlerInterests = BabyStage.toddler.availableInterests
        XCTAssertEqual(toddlerInterests.count, Set(toddlerInterests).count)
        
        let preschoolerInterests = BabyStage.preschooler.availableInterests
        XCTAssertEqual(preschoolerInterests.count, Set(preschoolerInterests).count)
    }
    
    func testBabyStageProgression() {
        // Test that stages represent logical progression
        let allStages = BabyStage.allCases
        XCTAssertEqual(allStages.count, 5)
        
        // Test expected order
        XCTAssertEqual(allStages[0], .pregnancy)
        XCTAssertEqual(allStages[1], .newborn)
        XCTAssertEqual(allStages[2], .infant)
        XCTAssertEqual(allStages[3], .toddler)
        XCTAssertEqual(allStages[4], .preschooler)
    }
    
    func testBabyStageCodeable() throws {
        // Test encoding
        for stage in BabyStage.allCases {
            let encodedData = try JSONEncoder().encode(stage)
            XCTAssertNotNil(encodedData)
            
            // Test decoding
            let decodedStage = try JSONDecoder().decode(BabyStage.self, from: encodedData)
            XCTAssertEqual(stage, decodedStage)
        }
    }
    
    func testBabyStageFromRawValue() {
        // Test creating from raw values
        XCTAssertEqual(BabyStage(rawValue: "pregnancy"), .pregnancy)
        XCTAssertEqual(BabyStage(rawValue: "newborn"), .newborn)
        XCTAssertEqual(BabyStage(rawValue: "infant"), .infant)
        XCTAssertEqual(BabyStage(rawValue: "toddler"), .toddler)
        XCTAssertEqual(BabyStage(rawValue: "preschooler"), .preschooler)
        
        // Test invalid raw value
        XCTAssertNil(BabyStage(rawValue: "invalid"))
        XCTAssertNil(BabyStage(rawValue: ""))
    }
    
    func testBabyStageInterestsAreAgeAppropriate() {
        // Test that interests make sense for each stage
        
        // Pregnancy should focus on bonding and relaxation
        let pregnancyInterests = BabyStage.pregnancy.availableInterests
        XCTAssertTrue(pregnancyInterests.contains { $0.lowercased().contains("classical") || $0.lowercased().contains("music") })
        
        // Newborn should focus on comfort and basic needs
        let newbornInterests = BabyStage.newborn.availableInterests
        XCTAssertTrue(newbornInterests.contains { $0.lowercased().contains("lullabies") || $0.lowercased().contains("sleep") })
        
        // Infant should focus on discovery and development
        let infantInterests = BabyStage.infant.availableInterests
        XCTAssertTrue(infantInterests.contains { $0.lowercased().contains("peek") || $0.lowercased().contains("discovery") })
        
        // Toddler should focus on learning and exploration
        let toddlerInterests = BabyStage.toddler.availableInterests
        XCTAssertTrue(toddlerInterests.contains { $0.lowercased().contains("animals") || $0.lowercased().contains("colors") })
        
        // Preschooler should focus on complex concepts and social skills
        let preschoolerInterests = BabyStage.preschooler.availableInterests
        XCTAssertTrue(preschoolerInterests.contains { $0.lowercased().contains("adventure") || $0.lowercased().contains("friendship") })
    }
    
    func testBabyStageInterestsGrowInComplexity() {
        // Test that interests become more complex as stages progress
        let pregnancyCount = BabyStage.pregnancy.availableInterests.count
        let newbornCount = BabyStage.newborn.availableInterests.count
        let infantCount = BabyStage.infant.availableInterests.count
        let toddlerCount = BabyStage.toddler.availableInterests.count
        let preschoolerCount = BabyStage.preschooler.availableInterests.count
        
        // Later stages should generally have more interests (more options as child develops)
        XCTAssertGreaterThan(toddlerCount, pregnancyCount)
        XCTAssertGreaterThan(preschoolerCount, pregnancyCount)
        XCTAssertGreaterThanOrEqual(toddlerCount, newbornCount)
    }
}
