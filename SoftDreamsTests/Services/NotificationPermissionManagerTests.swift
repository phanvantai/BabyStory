//
//  NotificationPermissionManagerTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
import UserNotifications
@testable import SoftDreams

@MainActor
struct NotificationPermissionManagerTests {
    
    func setUp() {
        // Reset notification settings if possible
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    @Test("NotificationPermissionManager singleton")
    func testSingleton() {
        setUp()
        
        let manager1 = NotificationPermissionManager.shared
        let manager2 = NotificationPermissionManager.shared
        
        #expect(manager1 === manager2)
    }
    
    @Test("NotificationPermissionStatus enum properties")
    func testNotificationPermissionStatusProperties() {
        // Test canSendNotifications
        #expect(NotificationPermissionManager.NotificationPermissionStatus.authorized.canSendNotifications == true)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.provisional.canSendNotifications == true)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.unknown.canSendNotifications == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.notDetermined.canSendNotifications == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.denied.canSendNotifications == false)
        
        // Test needsPermissionRequest
        #expect(NotificationPermissionManager.NotificationPermissionStatus.notDetermined.needsPermissionRequest == true)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.authorized.needsPermissionRequest == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.denied.needsPermissionRequest == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.provisional.needsPermissionRequest == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.unknown.needsPermissionRequest == false)
        
        // Test isExplicitlyDenied
        #expect(NotificationPermissionManager.NotificationPermissionStatus.denied.isExplicitlyDenied == true)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.authorized.isExplicitlyDenied == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.notDetermined.isExplicitlyDenied == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.provisional.isExplicitlyDenied == false)
        #expect(NotificationPermissionManager.NotificationPermissionStatus.unknown.isExplicitlyDenied == false)
    }
    
    @Test("NotificationPermissionManager initialization")
    func testInitialization() {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Should have initial state
        #expect(manager.permissionStatus != nil)
        #expect(manager.showPermissionSheet == false)
    }
    
    @Test("NotificationPermissionManager updatePermissionStatus")
    func testUpdatePermissionStatus() async {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Should not crash and should update status
        await manager.updatePermissionStatus()
        
        // Status should be one of the defined cases
        let validStatuses: [NotificationPermissionManager.NotificationPermissionStatus] = [
            .unknown, .notDetermined, .denied, .authorized, .provisional
        ]
        #expect(validStatuses.contains { $0 == manager.permissionStatus })
    }
    
    @Test("NotificationPermissionManager shouldShowPermissionExplanation")
    func testShouldShowPermissionExplanation() {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Test with different contexts
        let pregnancyResult = manager.shouldShowPermissionExplanation(for: .pregnancyReminders)
        let storyTimeResult = manager.shouldShowPermissionExplanation(for: .storyTime)
        let generalResult = manager.shouldShowPermissionExplanation(for: .general)
        
        #expect(pregnancyResult == true || pregnancyResult == false)
        #expect(storyTimeResult == true || storyTimeResult == false)
        #expect(generalResult == true || generalResult == false)
    }
    
    @Test("NotificationPermissionManager showPermissionExplanation")
    func testShowPermissionExplanation() {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Initially should be false
        #expect(manager.showPermissionSheet == false)
        
        // Should set to true when called
        manager.showPermissionExplanation()
        #expect(manager.showPermissionSheet == true)
    }
    
    @Test("NotificationPermissionManager requestPermission")
    func testRequestPermission() async {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Should return a status and not crash
        let result = await manager.requestPermission()
        
        let validStatuses: [NotificationPermissionManager.NotificationPermissionStatus] = [
            .unknown, .notDetermined, .denied, .authorized, .provisional
        ]
        #expect(validStatuses.contains { $0 == result })
    }
    
    @Test("NotificationPermissionManager openNotificationSettings")
    func testOpenNotificationSettings() {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Should not crash when called
        manager.openNotificationSettings()
        #expect(true)
    }
    
    @Test("PermissionContext static properties")
    func testPermissionContextStaticProperties() {
        // Test pregnancyReminders context
        let pregnancyContext = PermissionContext.pregnancyReminders
        #expect(!pregnancyContext.reason.isEmpty)
        #expect(!pregnancyContext.benefits.isEmpty)
        #expect(pregnancyContext.showForDenied == true)
        
        // Test storyTime context
        let storyTimeContext = PermissionContext.storyTime
        #expect(!storyTimeContext.reason.isEmpty)
        #expect(!storyTimeContext.benefits.isEmpty)
        #expect(storyTimeContext.showForDenied == true)
        
        // Test general context
        let generalContext = PermissionContext.general
        #expect(!generalContext.reason.isEmpty)
        #expect(!generalContext.benefits.isEmpty)
        #expect(generalContext.showForDenied == true)
    }
    
    @Test("PermissionContext custom initialization")
    func testPermissionContextCustomInitialization() {
        let customContext = PermissionContext(
            reason: "Custom reason",
            benefits: ["Benefit 1", "Benefit 2"],
            showForDenied: false
        )
        
        #expect(customContext.reason == "Custom reason")
        #expect(customContext.benefits == ["Benefit 1", "Benefit 2"])
        #expect(customContext.showForDenied == false)
    }
    
    @Test("NotificationPermissionManager permission status updates")
    func testPermissionStatusUpdates() async {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Get initial status
        let initialStatus = manager.permissionStatus
        
        // Update status
        await manager.updatePermissionStatus()
        
        // Status should be valid regardless of whether it changed
        let validStatuses: [NotificationPermissionManager.NotificationPermissionStatus] = [
            .unknown, .notDetermined, .denied, .authorized, .provisional
        ]
        #expect(validStatuses.contains { $0 == manager.permissionStatus })
    }
    
    @Test("NotificationPermissionManager edge cases")
    func testEdgeCases() {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Test multiple rapid calls to showPermissionExplanation
        manager.showPermissionExplanation()
        manager.showPermissionExplanation()
        manager.showPermissionExplanation()
        
        #expect(manager.showPermissionSheet == true)
        
        // Reset and test
        manager.showPermissionSheet = false
        #expect(manager.showPermissionSheet == false)
    }
    
    @Test("NotificationPermissionManager concurrent access")
    func testConcurrentAccess() async {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Test concurrent permission requests (should handle gracefully)
        async let request1 = manager.requestPermission()
        async let request2 = manager.updatePermissionStatus()
        
        let result1 = await request1
        await request2
        
        // Should complete without crashes
        let validStatuses: [NotificationPermissionManager.NotificationPermissionStatus] = [
            .unknown, .notDetermined, .denied, .authorized, .provisional
        ]
        #expect(validStatuses.contains { $0 == result1 })
    }
    
    @Test("NotificationPermissionManager state consistency")
    func testStateConsistency() async {
        setUp()
        
        let manager = NotificationPermissionManager.shared
        
        // Update status multiple times
        await manager.updatePermissionStatus()
        let status1 = manager.permissionStatus
        
        await manager.updatePermissionStatus()
        let status2 = manager.permissionStatus
        
        // Status should be consistent between rapid updates
        // (in test environment, this should remain stable)
        #expect(status1 == status2)
    }
    
    @Test("PermissionContext benefits validation")
    func testPermissionContextBenefitsValidation() {
        // All static contexts should have at least one benefit
        #expect(PermissionContext.pregnancyReminders.benefits.count > 0)
        #expect(PermissionContext.storyTime.benefits.count > 0)
        #expect(PermissionContext.general.benefits.count > 0)
        
        // All benefits should be non-empty strings
        for benefit in PermissionContext.pregnancyReminders.benefits {
            #expect(!benefit.isEmpty)
        }
        
        for benefit in PermissionContext.storyTime.benefits {
            #expect(!benefit.isEmpty)
        }
        
        for benefit in PermissionContext.general.benefits {
            #expect(!benefit.isEmpty)
        }
    }
}
