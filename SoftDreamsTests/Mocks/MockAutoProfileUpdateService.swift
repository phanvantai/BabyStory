//
//  MockAutoProfileUpdateService.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
@testable import SoftDreams

class MockAutoProfileUpdateService: AutoProfileUpdateServiceProtocol {
    var performAutoUpdateResult = AutoUpdateResult()
    var performAutoUpdateCalled = false
    
    func performAutoUpdate() async -> AutoUpdateResult {
        performAutoUpdateCalled = true
        return performAutoUpdateResult
    }
    
    func performAutoUpdate(profile: UserProfile?) async -> AutoUpdateResult {
        performAutoUpdateCalled = true
        return performAutoUpdateResult
    }
    
    func updateProfileIfNeeded() async {
        let _ = await performAutoUpdate()
    }
    
    func setupDueDateNotifications() async {
        // Mock implementation
    }
    
    func needsAutoUpdate(profile: UserProfile?) -> Bool {
        return false
    }
}
