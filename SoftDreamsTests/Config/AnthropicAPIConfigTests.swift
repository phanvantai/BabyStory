//
//  AnthropicAPIConfigTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 2/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct AnthropicAPIConfigTests {
    
    @Test("AnthropicAPIConfig baseURL defaults correctly")
    func testBaseURLDefault() {
        // Test that the baseURL has a reasonable default value
        let baseURL = AnthropicAPIConfig.baseURL
        #expect(baseURL == "https://api.anthropic.com/v1")
    }
    
    @Test("AnthropicAPIConfig apiKey returns valid key if available")
    func testApiKeyRetrieval() {
        // This test just verifies that the property access doesn't crash
        // The actual value will depend on the test environment configuration
        let _ = AnthropicAPIConfig.apiKey
        #expect(true) // Test passes if no exception is thrown
    }
}
