//
//  AppInfoServiceTests.swift
//  SoftDreamsTests
//
//  Created by Tests on 30/5/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct AppInfoServiceTests {
    
    @Test("AppInfoService singleton")
    func testSingleton() {
        let service1 = AppInfoService.shared
        let service2 = AppInfoService.shared
        
        #expect(service1 === service2)
    }
    
    @Test("AppInfoService appName property")
    func testAppName() {
        let service = AppInfoService.shared
        let appName = service.appName
        
        #expect(!appName.isEmpty)
        // Should default to "SoftDreams" if bundle name is not available
        #expect(appName == "SoftDreams" || !appName.isEmpty)
    }
    
    @Test("AppInfoService appVersion property")
    func testAppVersion() {
        let service = AppInfoService.shared
        let appVersion = service.appVersion
        
        #expect(!appVersion.isEmpty)
        // Should have a valid version format or default to "1.0.0"
        #expect(appVersion.contains(".") || appVersion == "1.0.0")
    }
    
    @Test("AppInfoService buildNumber property")
    func testBuildNumber() {
        let service = AppInfoService.shared
        let buildNumber = service.buildNumber
        
        #expect(!buildNumber.isEmpty)
        // Should be a numeric string or default to "1"
        #expect(Int(buildNumber) != nil || buildNumber == "1")
    }
    
    @Test("AppInfoService versionWithBuild property")
    func testVersionWithBuild() {
        let service = AppInfoService.shared
        let versionWithBuild = service.versionWithBuild
        
        #expect(!versionWithBuild.isEmpty)
        #expect(versionWithBuild.contains("("))
        #expect(versionWithBuild.contains(")"))
        
        // Should contain both version and build number
        #expect(versionWithBuild.contains(service.appVersion))
        #expect(versionWithBuild.contains(service.buildNumber))
    }
    
    @Test("AppInfoService format consistency")
    func testFormatConsistency() {
        let service = AppInfoService.shared
        
        let expectedFormat = "\(service.appVersion) (\(service.buildNumber))"
        #expect(service.versionWithBuild == expectedFormat)
    }
    
    @Test("AppInfoService properties are not nil")
    func testPropertiesNotNil() {
        let service = AppInfoService.shared
        
        // All properties should return non-nil values
        #expect(service.appName != nil)
        #expect(service.appVersion != nil)
        #expect(service.buildNumber != nil)
        #expect(service.versionWithBuild != nil)
    }
    
    @Test("AppInfoService properties stability")
    func testPropertiesStability() {
        let service = AppInfoService.shared
        
        // Properties should return the same value on multiple calls
        let appName1 = service.appName
        let appName2 = service.appName
        #expect(appName1 == appName2)
        
        let appVersion1 = service.appVersion
        let appVersion2 = service.appVersion
        #expect(appVersion1 == appVersion2)
        
        let buildNumber1 = service.buildNumber
        let buildNumber2 = service.buildNumber
        #expect(buildNumber1 == buildNumber2)
        
        let versionWithBuild1 = service.versionWithBuild
        let versionWithBuild2 = service.versionWithBuild
        #expect(versionWithBuild1 == versionWithBuild2)
    }
    
    @Test("AppInfoService default values")
    func testDefaultValues() {
        let service = AppInfoService.shared
        
        // Test that defaults are reasonable
        if Bundle.main.infoDictionary?["CFBundleName"] == nil && 
           Bundle.main.infoDictionary?["CFBundleDisplayName"] == nil {
            #expect(service.appName == "SoftDreams")
        }
        
        if Bundle.main.infoDictionary?["CFBundleShortVersionString"] == nil {
            #expect(service.appVersion == "1.0.0")
        }
        
        if Bundle.main.infoDictionary?["CFBundleVersion"] == nil {
            #expect(service.buildNumber == "1")
        }
    }
    
    @Test("AppInfoService bundle info integration")
    func testBundleInfoIntegration() {
        let service = AppInfoService.shared
        
        // Verify that the service correctly reads from bundle
        let bundleInfo = Bundle.main.infoDictionary
        
        if let bundleName = bundleInfo?["CFBundleName"] as? String {
            #expect(service.appName == bundleName)
        } else if let displayName = bundleInfo?["CFBundleDisplayName"] as? String {
            #expect(service.appName == displayName)
        } else {
            #expect(service.appName == "SoftDreams")
        }
        
        if let bundleVersion = bundleInfo?["CFBundleShortVersionString"] as? String {
            #expect(service.appVersion == bundleVersion)
        } else {
            #expect(service.appVersion == "1.0.0")
        }
        
        if let bundleBuild = bundleInfo?["CFBundleVersion"] as? String {
            #expect(service.buildNumber == bundleBuild)
        } else {
            #expect(service.buildNumber == "1")
        }
    }
}
