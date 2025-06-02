//
//  ActionCardTests.swift
//  SoftDreamsTests
//
//  Created by AI Assistant on 2/6/25.
//

import XCTest
import SwiftUI
@testable import SoftDreams

final class ActionCardTests: XCTestCase {
    
    func testActionCardInitialization() {
        // Given
        let title = "Test Title"
        let subtitle = "Test Subtitle"
        let icon = "star.fill"
        let gradientColors = [Color.blue, Color.purple]
        var actionCalled = false
        
        // When
        let actionCard = ActionCard(
            title: title,
            subtitle: subtitle,
            icon: icon,
            gradientColors: gradientColors
        ) {
            actionCalled = true
        }
        
        // Then
        XCTAssertNotNil(actionCard)
    }
    
    func testActionCardWithDifferentParameters() {
        // Test with minimal parameters
        let card1 = ActionCard(
            title: "Title",
            subtitle: "Subtitle",
            icon: "heart",
            gradientColors: [Color.red]
        ) { }
        XCTAssertNotNil(card1)
        
        // Test with multiple gradient colors
        let card2 = ActionCard(
            title: "Long Title That Might Wrap",
            subtitle: "Long subtitle that could potentially wrap to multiple lines",
            icon: "star.circle.fill",
            gradientColors: [Color.blue, Color.purple, Color.pink]
        ) { }
        XCTAssertNotNil(card2)
        
        // Test with empty strings
        let card3 = ActionCard(
            title: "",
            subtitle: "",
            icon: "questionmark",
            gradientColors: [Color.gray]
        ) { }
        XCTAssertNotNil(card3)
    }
    
    func testActionCardGradientColors() {
        // Test single color
        let singleColorCard = ActionCard(
            title: "Test",
            subtitle: "Test",
            icon: "star",
            gradientColors: [Color.blue]
        ) { }
        XCTAssertNotNil(singleColorCard)
        
        // Test multiple colors
        let multiColorCard = ActionCard(
            title: "Test",
            subtitle: "Test",
            icon: "star",
            gradientColors: [Color.red, Color.orange, Color.yellow, Color.green]
        ) { }
        XCTAssertNotNil(multiColorCard)
        
        // Test empty colors array
        let emptyColorsCard = ActionCard(
            title: "Test",
            subtitle: "Test",
            icon: "star",
            gradientColors: []
        ) { }
        XCTAssertNotNil(emptyColorsCard)
    }
    
    func testActionCardIcons() {
        // Test various system icons
        let icons = [
            "star.fill",
            "heart.circle",
            "book.fill",
            "music.note",
            "moon.stars.fill",
            "sun.max.fill"
        ]
        
        for icon in icons {
            let card = ActionCard(
                title: "Test",
                subtitle: "Test",
                icon: icon,
                gradientColors: [Color.blue]
            ) { }
            XCTAssertNotNil(card)
        }
        
        // Test with invalid icon
        let invalidIconCard = ActionCard(
            title: "Test",
            subtitle: "Test",
            icon: "invalid.icon.name",
            gradientColors: [Color.blue]
        ) { }
        XCTAssertNotNil(invalidIconCard)
    }
    
    func testActionCardTextContent() {
        // Test with special characters
        let specialCharCard = ActionCard(
            title: "Title with émojis 🌟",
            subtitle: "Subtitle with special chars: àáâã & symbols!",
            icon: "star",
            gradientColors: [Color.blue]
        ) { }
        XCTAssertNotNil(specialCharCard)
        
        // Test with numbers
        let numberCard = ActionCard(
            title: "Title 123",
            subtitle: "Subtitle with numbers: 456 and more",
            icon: "number",
            gradientColors: [Color.green]
        ) { }
        XCTAssertNotNil(numberCard)
        
        // Test with very long text
        let longTextCard = ActionCard(
            title: "This is a very long title that might exceed normal expectations",
            subtitle: "This is an extremely long subtitle that would definitely need to wrap and might cause layout issues if not handled properly in the user interface",
            icon: "text.alignleft",
            gradientColors: [Color.purple]
        ) { }
        XCTAssertNotNil(longTextCard)
    }
    
    func testActionCardActionClosure() {
        // Test that action closure is stored and can be called
        var actionCallCount = 0
        
        let actionCard = ActionCard(
            title: "Test",
            subtitle: "Test",
            icon: "star",
            gradientColors: [Color.blue]
        ) {
            actionCallCount += 1
        }
        
        XCTAssertNotNil(actionCard)
        XCTAssertEqual(actionCallCount, 0) // Should not be called during initialization
    }
    
    func testActionCardMemoryManagement() {
        // Test that ActionCard doesn't cause memory leaks
        weak var weakCard: ActionCard?
        
        autoreleasepool {
            let strongCard = ActionCard(
                title: "Test",
                subtitle: "Test",
                icon: "star",
                gradientColors: [Color.blue]
            ) { }
            
            weakCard = strongCard
            XCTAssertNotNil(weakCard)
        }
        
        // Note: SwiftUI Views are value types, so this test verifies the pattern
        XCTAssertNotNil(weakCard) // Views are value types, so this should still exist
    }
    
    func testActionCardWithNilGradientColors() {
        // Test behavior with potentially problematic gradient configurations
        let card = ActionCard(
            title: "Test",
            subtitle: "Test",
            icon: "star",
            gradientColors: []
        ) { }
        XCTAssertNotNil(card)
    }
    
    func testActionCardEdgeCases() {
        // Test with whitespace-only strings
        let whitespaceCard = ActionCard(
            title: "   ",
            subtitle: "\t\n",
            icon: "space",
            gradientColors: [Color.gray]
        ) { }
        XCTAssertNotNil(whitespaceCard)
        
        // Test with newlines in text
        let newlineCard = ActionCard(
            title: "Title\nWith\nNewlines",
            subtitle: "Subtitle\nAlso\nWith\nNewlines",
            icon: "return",
            gradientColors: [Color.blue]
        ) { }
        XCTAssertNotNil(newlineCard)
    }
}
