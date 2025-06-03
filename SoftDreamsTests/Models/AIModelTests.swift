//
//  AIModelTests.swift
//  SoftDreamsTests
//
//  Created by GitHub Copilot on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct AIModelTests {
    
    @Test("Test AIModel case values and raw values")
    func testAIModelValues() async throws {
        #expect(AIModel.gpt35Turbo.rawValue == "gpt-3.5-turbo")
        #expect(AIModel.gpt4o.rawValue == "gpt-4o")
        #expect(AIModel.claude3Haiku.rawValue == "claude-3-haiku-20240307")
        #expect(AIModel.claude3Sonnet.rawValue == "claude-3-sonnet-20240229")
        #expect(AIModel.geminiPro.rawValue == "gemini-pro")
    }
    
    @Test("Test AIModel allCases")
    func testAIModelAllCases() async throws {
        let allCases = AIModel.allCases
        #expect(allCases.count == 5)
        #expect(allCases.contains(.gpt35Turbo))
        #expect(allCases.contains(.gpt4o))
        #expect(allCases.contains(.claude3Haiku))
        #expect(allCases.contains(.claude3Sonnet))
        #expect(allCases.contains(.geminiPro))
    }
    
    @Test("Test AIModel displayName localization")
    func testAIModelDisplayName() async throws {
        // Test that display names are not empty and are localized
        for model in AIModel.allCases {
            #expect(!model.displayName.isEmpty, "Display name should not be empty for \(model)")
            #expect(model.displayName.contains("ai_model_") == false, "Display name should be localized, not contain key for \(model)")
        }
    }
    
    @Test("Test AIModel description localization")
    func testAIModelDescription() async throws {
        // Test that descriptions are not empty and are localized
        for model in AIModel.allCases {
            #expect(!model.description.isEmpty, "Description should not be empty for \(model)")
            #expect(model.description.contains("ai_model_") == false, "Description should be localized, not contain key for \(model)")
        }
    }
    
    @Test("Test AIModel isPremium property")
    func testAIModelIsPremium() async throws {
        // Only GPT-3.5 Turbo should be free
        #expect(AIModel.gpt35Turbo.isPremium == false)
        
        // All other models should be premium
        #expect(AIModel.gpt4o.isPremium == true)
        #expect(AIModel.claude3Haiku.isPremium == true)
        #expect(AIModel.claude3Sonnet.isPremium == true)
        #expect(AIModel.geminiPro.isPremium == true)
    }
    
    @Test("Test AIModel provider property")
    func testAIModelProvider() async throws {
        #expect(AIModel.gpt35Turbo.provider == .openAI)
        #expect(AIModel.gpt4o.provider == .openAI)
        #expect(AIModel.claude3Haiku.provider == .anthropic)
        #expect(AIModel.claude3Sonnet.provider == .anthropic)
        #expect(AIModel.geminiPro.provider == .google)
    }
    
    @Test("Test AIModel icon property")
    func testAIModelIcon() async throws {
        // Test that all models have valid SF Symbols icons
        for model in AIModel.allCases {
            #expect(!model.icon.isEmpty, "Icon should not be empty for \(model)")
        }
        
        // Test specific expected icons
        #expect(AIModel.gpt35Turbo.icon == "bolt.circle")
        #expect(AIModel.gpt4o.icon == "sparkles.circle")
        #expect(AIModel.claude3Haiku.icon == "heart.circle")
        #expect(AIModel.claude3Sonnet.icon == "heart.circle.fill")
        #expect(AIModel.geminiPro.icon == "star.circle")
    }
    
    @Test("Test AIModel maxTokens property")
    func testAIModelMaxTokens() async throws {
        // Test that all models have reasonable token limits for story generation
        for model in AIModel.allCases {
            #expect(model.maxTokens > 0, "Max tokens should be positive for \(model)")
            #expect(model.maxTokens >= 1000, "Max tokens should be at least 1000 for story generation for \(model)")
            #expect(model.maxTokens <= 4000, "Max tokens should be reasonable for mobile app for \(model)")
        }
    }
    
    @Test("Test AIModel temperature property")
    func testAIModelTemperature() async throws {
        // Test that all models have reasonable temperature values for creative writing
        for model in AIModel.allCases {
            #expect(model.temperature >= 0.0, "Temperature should be non-negative for \(model)")
            #expect(model.temperature <= 1.0, "Temperature should not exceed 1.0 for \(model)")
            #expect(model.temperature >= 0.7, "Temperature should be at least 0.7 for creative story writing for \(model)")
        }
    }
    
    @Test("Test AIModel equality")
    func testAIModelEquality() async throws {
        let model1 = AIModel.gpt35Turbo
        let model2 = AIModel.gpt35Turbo
        let model3 = AIModel.gpt4o
        
        #expect(model1 == model2)
        #expect(model1 != model3)
    }
    
    @Test("Test AIModel codable")
    func testAIModelCodable() async throws {
        let models = AIModel.allCases
        
        for model in models {
            // Test encoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(model)
            #expect(!data.isEmpty, "Should be able to encode \(model)")
            
            // Test decoding
            let decoder = JSONDecoder()
            let decodedModel = try decoder.decode(AIModel.self, from: data)
            #expect(decodedModel == model, "Decoded model should equal original for \(model)")
        }
    }
    
    @Test("Test AIModel free models")
    func testFreeModels() async throws {
        let freeModels = AIModel.freeModels
        #expect(freeModels.count == 1, "Should have exactly one free model")
        #expect(freeModels.contains(.gpt35Turbo), "GPT-3.5 Turbo should be the free model")
    }
    
    @Test("Test AIModel premium models")
    func testPremiumModels() async throws {
        let premiumModels = AIModel.premiumModels
        #expect(premiumModels.count == 4, "Should have exactly four premium models")
        #expect(premiumModels.contains(.gpt4o), "GPT-4o should be premium")
        #expect(premiumModels.contains(.claude3Haiku), "Claude 3 Haiku should be premium")
        #expect(premiumModels.contains(.claude3Sonnet), "Claude 3 Sonnet should be premium")
        #expect(premiumModels.contains(.geminiPro), "Gemini Pro should be premium")
        #expect(!premiumModels.contains(.gpt35Turbo), "GPT-3.5 Turbo should not be premium")
    }
    
    @Test("Test AIModel default model")
    func testDefaultModel() async throws {
        #expect(AIModel.default == .gpt35Turbo, "Default model should be GPT-3.5 Turbo (free model)")
    }
}
