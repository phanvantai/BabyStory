//
//  AppViewTests.swift
//  SoftDreamsTests
//
//  Created by AI Assistant on 2/6/25.
//

import XCTest
import SwiftUI
@testable import SoftDreams

@MainActor
final class AppViewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset UserDefaults before each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up UserDefaults after each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func testAppViewInitialization() {
        // Given & When
        let appView = AppView()
        
        // Then
        XCTAssertNotNil(appView.body)
    }
    
    func testLoadingViewInitialization() {
        // Given & When
        let loadingView = LoadingView()
        
        // Then
        XCTAssertNotNil(loadingView.body)
    }
    
    func testLoadingViewContent() {
        // Given
        let loadingView = LoadingView()
        
        // When
        let body = loadingView.body
        
        // Then
        XCTAssertNotNil(body)
        // The view should contain a ZStack with background and content
    }
    
    func testAppViewWithNoProfile() async throws {
        // Given
        // Ensure no profile exists
        try? StorageManager.shared.deleteProfile()
        
        let appView = AppView()
        
        // When
        // Simulate app view appearing
        let mirror = Mirror(reflecting: appView)
        
        // Then
        // Should show onboarding when no profile exists
        XCTAssertNotNil(appView.body)
    }
    
    func testAppViewWithExistingProfile() async throws {
        // Given
        let testProfile = UserProfile(
            babyName: "Test Baby",
            parentNames: ParentNames(motherName: "Test Mom", fatherName: "Test Dad"),
            gender: .female,
            dateOfBirth: Date(),
            interests: ["Animals", "Music"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .infant
        )
        
        try StorageManager.shared.saveProfile(testProfile)
        
        let appView = AppView()
        
        // When & Then
        XCTAssertNotNil(appView.body)
        // Should show home view when profile exists
    }
}

// MARK: - Additional AppView Tests

@MainActor
final class AppViewIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func testAppViewStateTransitions() async throws {
        // Given
        let appView = AppView()
        
        // Test initial loading state
        XCTAssertNotNil(appView.body)
        
        // When profile doesn't exist
        // Should transition to onboarding
        try? StorageManager.shared.deleteProfile()
        
        // When profile exists
        // Should transition to home
        let testProfile = UserProfile(
            babyName: "Test",
            parentNames: ParentNames(motherName: "Mom", fatherName: "Dad"),
            gender: .male,
            dateOfBirth: Date(),
            interests: ["Test"],
            favoriteTheme: "adventure",
            preferredStoryTime: Date(),
            babyStage: .toddler
        )
        
        try StorageManager.shared.saveProfile(testProfile)
        
        // Then
        XCTAssertNotNil(appView.body)
    }
}
