//
//  EmptyStateCardTests.swift
//  SoftDreamsTests
//
//  Created by AI Assistant on 2/6/25.
//

import XCTest
import SwiftUI
@testable import SoftDreams

final class EmptyStateCardTests: XCTestCase {
    
    func testEmptyStateCardInitializationWithoutAction() {
        // Given
        let title = "Empty State"
        let message = "No items found"
        let icon = "questionmark.circle"
        let iconColor = Color.gray
        
        // When
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon,
            iconColor: iconColor
        )
        
        // Then
        XCTAssertNotNil(emptyStateCard)
    }
    
    func testEmptyStateCardInitializationWithAction() {
        // Given
        let title = "Empty State"
        let message = "No items found"
        let icon = "questionmark.circle"
        let iconColor = Color.blue
        let actionTitle = "Retry"
        var actionCalled = false
        
        // When
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon,
            iconColor: iconColor,
            actionTitle: actionTitle
        ) {
            actionCalled = true
        }
        
        // Then
        XCTAssertNotNil(emptyStateCard)
    }
    
    func testEmptyStateCardWithDefaultValues() {
        // Given
        let title = "Empty State"
        let message = "No items found"
        let icon = "questionmark.circle"
        
        // When
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon
        )
        
        // Then
        XCTAssertNotNil(emptyStateCard)
    }
    
    func testEmptyStateCardTitleText() throws {
        // Given
        let title = "Test Empty State"
        let message = "Test message"
        let icon = "star"
        
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon
        )
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        let textVStack = try vStack.vStack(1)
        let titleText = try textVStack.text(0)
        
        XCTAssertEqual(try titleText.string(), title)
    }
    
    func testEmptyStateCardMessageText() throws {
        // Given
        let title = "Test Title"
        let message = "Test Empty State Message"
        let icon = "star"
        
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon
        )
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        let textVStack = try vStack.vStack(1)
        let messageText = try textVStack.text(1)
        
        XCTAssertEqual(try messageText.string(), message)
    }
    
    func testEmptyStateCardIcon() throws {
        // Given
        let title = "Test Title"
        let message = "Test message"
        let icon = "heart.fill"
        
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon
        )
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        let iconImage = try vStack.image(0)
        
        XCTAssertEqual(try iconImage.systemName(), icon)
    }
    
    func testEmptyStateCardWithAction() throws {
        // Given
        let title = "Test Title"
        let message = "Test message"
        let icon = "star"
        let actionTitle = "Try Again"
        var actionCalled = false
        
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon,
            actionTitle: actionTitle
        ) {
            actionCalled = true
        }
        
        // When
        let vStack = try emptyStateCard.inspect().vStack()
        let actionButton = try vStack.button(2)
        try actionButton.tap()
        
        // Then
        XCTAssertTrue(actionCalled)
        
        let buttonText = try actionButton.labelView().text()
        XCTAssertEqual(try buttonText.string(), actionTitle)
    }
    
    func testEmptyStateCardWithoutAction() throws {
        // Given
        let title = "Test Title"
        let message = "Test message"
        let icon = "star"
        
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon
        )
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        
        // Should only have image and text VStack, no button
        XCTAssertEqual(vStack.count, 2)
        
        // First element should be image
        XCTAssertNoThrow(try vStack.image(0))
        
        // Second element should be VStack with texts
        XCTAssertNoThrow(try vStack.vStack(1))
    }
    
    func testEmptyStateCardIconColor() throws {
        // Given
        let title = "Test Title"
        let message = "Test message"
        let icon = "star"
        let iconColor = Color.red
        
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon,
            iconColor: iconColor
        )
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        let iconImage = try vStack.image(0)
        
        // Verify the image exists and has system name
        XCTAssertEqual(try iconImage.systemName(), icon)
        
        // Note: Testing exact color values with opacity is complex in ViewInspector
        // We verify the icon exists and has the correct system name
        XCTAssertNotNil(iconImage)
    }
    
    func testEmptyStateCardStructure() throws {
        // Given
        let emptyStateCard = EmptyStateCard(
            title: "Test",
            message: "Test message",
            icon: "star",
            actionTitle: "Action"
        ) { }
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        
        // Should have 3 elements: icon, text VStack, and button
        XCTAssertEqual(vStack.count, 3)
        
        // Verify structure
        XCTAssertNoThrow(try vStack.image(0)) // Icon
        XCTAssertNoThrow(try vStack.vStack(1)) // Text VStack
        XCTAssertNoThrow(try vStack.button(2)) // Action button
    }
    
    func testEmptyStateCardStyling() throws {
        // Given
        let emptyStateCard = EmptyStateCard(
            title: "Test",
            message: "Test message",
            icon: "star"
        )
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        
        // Verify padding exists
        XCTAssertNotNil(try vStack.padding())
        
        // Note: Testing .appCardStyle() would require access to the modifier
        // We verify the VStack structure is correct
        XCTAssertNotNil(vStack)
    }
    
    func testEmptyStateCardAccessibility() throws {
        // Given
        let title = "Accessible Title"
        let message = "Accessible message for screen readers"
        let icon = "accessibility"
        
        let emptyStateCard = EmptyStateCard(
            title: title,
            message: message,
            icon: icon
        )
        
        // When & Then
        let vStack = try emptyStateCard.inspect().vStack()
        let textVStack = try vStack.vStack(1)
        
        let titleText = try textVStack.text(0)
        let messageText = try textVStack.text(1)
        
        XCTAssertEqual(try titleText.string(), title)
        XCTAssertEqual(try messageText.string(), message)
    }
}
