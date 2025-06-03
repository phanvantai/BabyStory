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
}
