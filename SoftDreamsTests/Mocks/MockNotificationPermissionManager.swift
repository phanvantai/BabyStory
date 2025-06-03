//
//  MockNotificationPermissionManager.swift
//  SoftDreamsTests
//
//  Created by Tests on 3/6/25.
//

import Foundation
import SwiftUI
@testable import SoftDreams

// MARK: - Mock Notification Permission Manager for Testing
class MockNotificationPermissionManager: ObservableObject, NotificationPermissionManagerProtocol {
    @Published var permissionStatus: NotificationPermissionStatus = .notDetermined
    @Published var showPermissionSheet = false
    
    var shouldGrantPermission = true
    var shouldShowExplanation = false
    
    func updatePermissionStatus() async {
        // Mock implementation - just update the status based on our test scenario
        permissionStatus = shouldGrantPermission ? .authorized : .denied
    }
    
    func shouldShowPermissionExplanation(for context: PermissionContext) -> Bool {
        return shouldShowExplanation
    }
    
    func showPermissionExplanation() {
        // Mock implementation - just set the flag
        showPermissionSheet = true
    }
    
    func requestPermission() async -> NotificationPermissionStatus {
        // Mock implementation - return permission based on our test scenario
        if shouldGrantPermission {
            permissionStatus = .authorized
        } else {
            permissionStatus = .denied
        }
        return permissionStatus
    }
    
    func openNotificationSettings() {
        // Mock implementation - do nothing for tests
    }
}
