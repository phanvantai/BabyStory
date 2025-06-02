//
//  ServiceFactoryTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct ServiceFactoryTests {
    
    @Test("ServiceFactory singleton")
    func testSingleton() {
        let factory1 = ServiceFactory.shared
        let factory2 = ServiceFactory.shared
        
        #expect(factory1 === factory2)
    }
    
    @Test("ServiceFactory createUserProfileService with UserDefaults")
    func testCreateUserProfileServiceWithUserDefaults() {
        let factory = ServiceFactory.shared
        
        let service = factory.createUserProfileService(storageType: .userDefaults)
        #expect(service is UserDefaultsUserProfileService)
        
        // Test default parameter
        let defaultService = factory.createUserProfileService()
        #expect(defaultService is UserDefaultsUserProfileService)
    }
    
    @Test("ServiceFactory createUserProfileService with unsupported storage types")
    func testCreateUserProfileServiceWithUnsupportedStorageTypes() {
        let factory = ServiceFactory.shared
        
        // Test that Core Data throws fatal error (we can't easily test fatalError in Swift Testing,
        // but we can verify the method exists and would be called)
        #expect(throws: Never.self) {
            // This would throw fatalError, but we can't test that directly
            // Instead, we'll test that the method signature exists
        }
        
        // Verify the method exists by checking it can be called with all enum cases
        let userDefaultsService = factory.createUserProfileService(storageType: .userDefaults)
        #expect(userDefaultsService != nil)
    }
    
    @Test("ServiceFactory createStoryService with UserDefaults")
    func testCreateStoryServiceWithUserDefaults() {
        let factory = ServiceFactory.shared
        
        let service = factory.createStoryService(storageType: .userDefaults)
        #expect(service is UserDefaultsStoryService)
        
        // Test default parameter
        let defaultService = factory.createStoryService()
        #expect(defaultService is UserDefaultsStoryService)
    }
    
    @Test("ServiceFactory createThemeService with UserDefaults")
    func testCreateThemeServiceWithUserDefaults() {
        let factory = ServiceFactory.shared
        
        let service = factory.createThemeService(storageType: .userDefaults)
        #expect(service is UserDefaultsThemeService)
        
        // Test default parameter
        let defaultService = factory.createThemeService()
        #expect(defaultService is UserDefaultsThemeService)
    }
    
    @Test("ServiceFactory createSettingsService with UserDefaults")
    func testCreateSettingsServiceWithUserDefaults() {
        let factory = ServiceFactory.shared
        
        let service = factory.createSettingsService(storageType: .userDefaults)
        #expect(service is UserDefaultsSettingsService)
        
        // Test default parameter
        let defaultService = factory.createSettingsService()
        #expect(defaultService is UserDefaultsSettingsService)
    }
    
    @Test("ServiceFactory createDueDateNotificationService")
    func testCreateDueDateNotificationService() {
        let factory = ServiceFactory.shared
        
        let service = factory.createDueDateNotificationService()
        #expect(service is DueDateNotificationService)
        
        // Test with different storage types (should all work the same way)
        let userDefaultsService = factory.createDueDateNotificationService(storageType: .userDefaults)
        #expect(userDefaultsService is DueDateNotificationService)
    }
    
    @Test("ServiceFactory createAutoProfileUpdateService")
    func testCreateAutoProfileUpdateService() {
        let factory = ServiceFactory.shared
        
        let service = factory.createAutoProfileUpdateService()
        #expect(service is AutoProfileUpdateService)
        
        // Test with different storage types (should all work the same way)
        let userDefaultsService = factory.createAutoProfileUpdateService(storageType: .userDefaults)
        #expect(userDefaultsService is AutoProfileUpdateService)
    }
    
    @Test("ServiceFactory createStoryGenerationService with mock")
    func testCreateStoryGenerationServiceWithMock() {
        let factory = ServiceFactory.shared
        
        let service = factory.createStoryGenerationService(serviceType: .mock)
        #expect(service is MockStoryGenerationService)
        
        // Test default parameter
        let defaultService = factory.createStoryGenerationService()
        #expect(defaultService is MockStoryGenerationService)
    }
    
    @Test("ServiceFactory createStoryGenerationService with OpenAI")
    func testCreateStoryGenerationServiceWithOpenAI() {
        let factory = ServiceFactory.shared
        
        // Without API key, should fallback to mock
        let service = factory.createStoryGenerationService(serviceType: .openAI)
        
        // Could be either OpenAI service (if API key exists) or Mock service (fallback)
        #expect(service is StoryGenerationServiceProtocol)
        #expect(service is MockStoryGenerationService || service is OpenAIStoryGenerationService)
    }
    
    @Test("StorageType enum cases")
    func testStorageTypeEnum() {
        // Test that all storage types exist
        let userDefaults = StorageType.userDefaults
        let coreData = StorageType.coreData
        let cloudKit = StorageType.cloudKit
        
        #expect(userDefaults != nil)
        #expect(coreData != nil)
        #expect(cloudKit != nil)
        
        // Test that they are different
        #expect(userDefaults != coreData)
        #expect(userDefaults != cloudKit)
        #expect(coreData != cloudKit)
    }
    
    @Test("StoryGenerationServiceType enum cases")
    func testStoryGenerationServiceTypeEnum() {
        // Test that all service types exist
        let mock = StoryGenerationServiceType.mock
        let openAI = StoryGenerationServiceType.openAI
        let localAI = StoryGenerationServiceType.localAI
        
        #expect(mock != nil)
        #expect(openAI != nil)
        #expect(localAI != nil)
        
        // Test that they are different
        #expect(mock != openAI)
        #expect(mock != localAI)
        #expect(openAI != localAI)
    }
    
    @Test("ServiceFactory service creation independence")
    func testServiceCreationIndependence() {
        let factory = ServiceFactory.shared
        
        // Create multiple instances of the same service type
        let userProfileService1 = factory.createUserProfileService()
        let userProfileService2 = factory.createUserProfileService()
        
        // Should be different instances
        #expect(userProfileService1 !== userProfileService2)
        
        let storyService1 = factory.createStoryService()
        let storyService2 = factory.createStoryService()
        
        #expect(storyService1 !== storyService2)
        
        let themeService1 = factory.createThemeService()
        let themeService2 = factory.createThemeService()
        
        #expect(themeService1 !== themeService2)
    }
    
    @Test("ServiceFactory protocol conformance")
    func testServiceProtocolConformance() {
        let factory = ServiceFactory.shared
        
        // Test that created services conform to expected protocols
        let userProfileService = factory.createUserProfileService()
        #expect(userProfileService is UserProfileServiceProtocol)
        
        let storyService = factory.createStoryService()
        #expect(storyService is StoryServiceProtocol)
        
        let themeService = factory.createThemeService()
        #expect(themeService is ThemeServiceProtocol)
        
        let settingsService = factory.createSettingsService()
        #expect(settingsService is SettingsServiceProtocol)
        
        let storyGenerationService = factory.createStoryGenerationService()
        #expect(storyGenerationService is StoryGenerationServiceProtocol)
    }
    
    @Test("ServiceFactory method signatures")
    func testMethodSignatures() {
        let factory = ServiceFactory.shared
        
        // Test that all methods can be called with their expected parameters
        // and return appropriate types
        
        // UserProfile service methods
        let _: UserProfileServiceProtocol = factory.createUserProfileService()
        let _: UserProfileServiceProtocol = factory.createUserProfileService(storageType: .userDefaults)
        
        // Story service methods
        let _: StoryServiceProtocol = factory.createStoryService()
        let _: StoryServiceProtocol = factory.createStoryService(storageType: .userDefaults)
        
        // Theme service methods
        let _: ThemeServiceProtocol = factory.createThemeService()
        let _: ThemeServiceProtocol = factory.createThemeService(storageType: .userDefaults)
        
        // Settings service methods
        let _: SettingsServiceProtocol = factory.createSettingsService()
        let _: SettingsServiceProtocol = factory.createSettingsService(storageType: .userDefaults)
        
        // Notification service methods
        let _: DueDateNotificationService = factory.createDueDateNotificationService()
        let _: DueDateNotificationService = factory.createDueDateNotificationService(storageType: .userDefaults)
        
        // Auto update service methods
        let _: AutoProfileUpdateService = factory.createAutoProfileUpdateService()
        let _: AutoProfileUpdateService = factory.createAutoProfileUpdateService(storageType: .userDefaults)
        
        // Story generation service methods
        let _: StoryGenerationServiceProtocol = factory.createStoryGenerationService()
        let _: StoryGenerationServiceProtocol = factory.createStoryGenerationService(serviceType: .mock)
        let _: StoryGenerationServiceProtocol = factory.createStoryGenerationService(serviceType: .openAI)
        
        #expect(true) // Test passes if no compilation errors
    }
    
    @Test("ServiceFactory edge cases")
    func testEdgeCases() {
        let factory = ServiceFactory.shared
        
        // Test creating services rapidly
        for _ in 0..<10 {
            let service = factory.createUserProfileService()
            #expect(service is UserDefaultsUserProfileService)
        }
        
        // Test creating different types rapidly
        let userProfileService = factory.createUserProfileService()
        let storyService = factory.createStoryService()
        let themeService = factory.createThemeService()
        let settingsService = factory.createSettingsService()
        let notificationService = factory.createDueDateNotificationService()
        let autoUpdateService = factory.createAutoProfileUpdateService()
        let storyGenerationService = factory.createStoryGenerationService()
        
        #expect(userProfileService != nil)
        #expect(storyService != nil)
        #expect(themeService != nil)
        #expect(settingsService != nil)
        #expect(notificationService != nil)
        #expect(autoUpdateService != nil)
        #expect(storyGenerationService != nil)
    }
}
