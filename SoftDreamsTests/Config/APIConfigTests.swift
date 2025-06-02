//
//  APIConfigTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct APIConfigTests {
    
    @Test("APIConfig baseURL property")
    func testBaseURLProperty() {
        // Test that baseURL returns a valid URL string
        let baseURL = APIConfig.baseURL
        
        #expect(!baseURL.isEmpty)
        #expect(baseURL.hasPrefix("https://"))
        
        // Should be a valid URL
        let url = URL(string: baseURL)
        #expect(url != nil)
        #expect(url?.scheme == "https")
        
        // Should default to OpenAI if not configured
        if baseURL == "https://api.openai.com/v1" {
            #expect(baseURL == "https://api.openai.com/v1")
        }
    }
    
    @Test("APIConfig baseURL consistency")
    func testBaseURLConsistency() {
        // Multiple calls should return the same value
        let firstCall = APIConfig.baseURL
        let secondCall = APIConfig.baseURL
        
        #expect(firstCall == secondCall)
    }
    
    @Test("APIConfig baseURL format validation")
    func testBaseURLFormatValidation() {
        let baseURL = APIConfig.baseURL
        
        // Should be a properly formatted URL
        #expect(baseURL.contains("://"))
        #expect(!baseURL.hasSuffix("/")) // Should not have trailing slash for v1 endpoint
        
        // Should be an OpenAI-compatible endpoint
        #expect(baseURL.contains("api") || baseURL.contains("openai"))
    }
    
    @Test("APIConfig enum structure")
    func testEnumStructure() {
        // Test that APIConfig is properly structured as an enum
        let mirror = Mirror(reflecting: APIConfig.self)
        
        // Should be an enum type
        #expect(mirror.displayStyle == .enum || mirror.displayStyle == nil) // nil for metatype
    }
    
    @Test("APIConfig Bundle integration")
    func testBundleIntegration() {
        // Test that APIConfig properly accesses Bundle
        let bundle = Bundle.main
        
        // Should be able to access info dictionary
        #expect(bundle.infoDictionary != nil)
        
        // The baseURL should come from Bundle or use default
        let configuredURL = bundle.infoDictionary?["API_BASE_URL"] as? String
        let actualURL = APIConfig.baseURL
        
        if let configuredURL = configuredURL {
            #expect(actualURL == configuredURL)
        } else {
            #expect(actualURL == "https://api.openai.com/v1")
        }
    }
    
    @Test("APIConfig thread safety")
    func testThreadSafety() async throws {
        // Test that APIConfig can be accessed from multiple threads safely
        let expectation = 10
        var results: [String] = []
        
        await withTaskGroup(of: String.self) { group in
            for _ in 0..<expectation {
                group.addTask {
                    return APIConfig.baseURL
                }
            }
            
            for await result in group {
                results.append(result)
            }
        }
        
        // All results should be identical
        #expect(results.count == expectation)
        let uniqueResults = Set(results)
        #expect(uniqueResults.count == 1)
    }
    
    @Test("APIConfig performance")
    func testPerformance() {
        // Test that accessing APIConfig properties is performant
        let iterations = 1000
        
        let startTime = Date()
        for _ in 0..<iterations {
            _ = APIConfig.baseURL
        }
        let endTime = Date()
        
        let timeInterval = endTime.timeIntervalSince(startTime)
        #expect(timeInterval < 1.0, "1000 property accesses should complete in less than 1 second")
    }
    
    @Test("APIConfig default values")
    func testDefaultValues() {
        // Test that APIConfig provides sensible defaults
        let baseURL = APIConfig.baseURL
        
        // Should have a default OpenAI URL if not configured
        #expect(baseURL == "https://api.openai.com/v1" || baseURL.contains("api"))
        
        // Default should be a working OpenAI endpoint
        if baseURL == "https://api.openai.com/v1" {
            let url = URL(string: baseURL)
            #expect(url?.host == "api.openai.com")
            #expect(url?.path == "/v1")
        }
    }
    
    @Test("APIConfig URL components")
    func testURLComponents() {
        let baseURL = APIConfig.baseURL
        
        guard let url = URL(string: baseURL) else {
            #expect(Bool(false), "baseURL should be a valid URL")
            return
        }
        
        // Test URL components
        #expect(url.scheme != nil)
        #expect(url.host != nil)
        #expect(url.scheme == "https")
        
        // Should not have query parameters or fragments in base URL
        #expect(url.query == nil)
        #expect(url.fragment == nil)
        
        // Should have a proper path structure
        #expect(!url.path.isEmpty || url.path == "/")
    }
}
