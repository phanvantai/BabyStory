//
//  StoryGenerationConfigTests.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Testing
import Foundation
@testable import SoftDreams

struct StoryGenerationConfigTests {
    
    // MARK: - Subscription Tier Tests
    
    @Test("Test SubscriptionTier case values")
    func testSubscriptionTierValues() async throws {
        #expect(SubscriptionTier.free.rawValue == "free")
        #expect(SubscriptionTier.premium.rawValue == "premium")
    }
    
    @Test("Test SubscriptionTier daily limits")
    func testSubscriptionTierDailyLimits() async throws {
        #expect(SubscriptionTier.free.dailyStoryLimit == 3)
        #expect(SubscriptionTier.premium.dailyStoryLimit == 10)
    }
    
    @Test("Test SubscriptionTier available models")
    func testSubscriptionTierAvailableModels() async throws {
        let freeModels = SubscriptionTier.free.availableModels
        let premiumModels = SubscriptionTier.premium.availableModels
        
        // Free tier should only have GPT-3.5 Turbo
        #expect(freeModels.count == 1)
        #expect(freeModels.contains(.gpt35Turbo))
        #expect(!freeModels.contains(.gpt4o))
        #expect(!freeModels.contains(.claude3Sonnet))
        
        // Premium tier should have all models
        #expect(premiumModels.count > 1)
        #expect(premiumModels.contains(.gpt35Turbo))
        #expect(premiumModels.contains(.gpt4o))
        #expect(premiumModels.contains(.claude3Sonnet))
    }
    
    @Test("Test SubscriptionTier default model")
    func testSubscriptionTierDefaultModel() async throws {
        #expect(SubscriptionTier.free.defaultModel == .gpt35Turbo)
        #expect(SubscriptionTier.premium.defaultModel == .gpt4o)
    }
    
    // MARK: - StoryGenerationConfig Tests
    
    @Test("Test StoryGenerationConfig initialization with free tier")
    func testStoryGenerationConfigInitializationFree() async throws {
        let config = StoryGenerationConfig(subscriptionTier: .free)
        
        #expect(config.subscriptionTier == .free)
        #expect(config.selectedModel == .gpt35Turbo)
        #expect(config.dailyStoryLimit == 3)
        #expect(config.storiesGeneratedToday == 0)
        #expect(config.lastResetDate != nil)
        #expect(config.canGenerateNewStory == true)
    }
    
    @Test("Test StoryGenerationConfig initialization with premium tier")
    func testStoryGenerationConfigInitializationPremium() async throws {
        let config = StoryGenerationConfig(subscriptionTier: .premium, selectedModel: .claude3Sonnet)
        
        #expect(config.subscriptionTier == .premium)
        #expect(config.selectedModel == .claude3Sonnet)
        #expect(config.dailyStoryLimit == 10)
        #expect(config.storiesGeneratedToday == 0)
        #expect(config.lastResetDate != nil)
        #expect(config.canGenerateNewStory == true)
    }
    
    @Test("Test StoryGenerationConfig daily limit enforcement")
    func testDailyLimitEnforcement() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .free)
        
        // Initially should be able to generate stories
        #expect(config.canGenerateNewStory == true)
        
        // Generate stories up to the limit
        for _ in 0..<3 {
            config.incrementStoryCount()
            if config.storiesGeneratedToday < 3 {
                #expect(config.canGenerateNewStory == true)
            }
        }
        
        // Should reach limit
        #expect(config.storiesGeneratedToday == 3)
        #expect(config.canGenerateNewStory == false)
        #expect(config.storiesRemainingToday == 0)
    }
    
    @Test("Test StoryGenerationConfig premium higher limits")
    func testPremiumHigherLimits() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .premium)
        
        // Generate stories up to free limit (should still be able to continue)
        for _ in 0..<3 {
            config.incrementStoryCount()
        }
        
        #expect(config.storiesGeneratedToday == 3)
        #expect(config.canGenerateNewStory == true)
        #expect(config.storiesRemainingToday == 7) // 10 - 3 = 7
        
        // Continue to premium limit
        for _ in 0..<7 {
            config.incrementStoryCount()
        }
        
        #expect(config.storiesGeneratedToday == 10)
        #expect(config.canGenerateNewStory == false)
        #expect(config.storiesRemainingToday == 0)
    }
    
    @Test("Test StoryGenerationConfig daily reset logic")
    func testDailyResetLogic() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .free)
        
        // Generate stories to reach limit
        for _ in 0..<3 {
            config.incrementStoryCount()
        }
        #expect(config.canGenerateNewStory == false)
        
        // Simulate next day reset
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        config.lastResetDate = yesterday
        
        // Check if reset is needed and reset
        #expect(config.shouldResetDailyCount == true)
        config.resetDailyCountIfNeeded()
        
        #expect(config.storiesGeneratedToday == 0)
        #expect(config.canGenerateNewStory == true)
        #expect(config.storiesRemainingToday == 3)
    }
    
    @Test("Test StoryGenerationConfig model availability validation")
    func testModelAvailabilityValidation() async throws {
        let freeConfig = StoryGenerationConfig(subscriptionTier: .free)
        let premiumConfig = StoryGenerationConfig(subscriptionTier: .premium)
        
        // Free user should only have access to GPT-3.5 Turbo
        #expect(freeConfig.isModelAvailable(.gpt35Turbo) == true)
        #expect(freeConfig.isModelAvailable(.gpt4o) == false)
        #expect(freeConfig.isModelAvailable(.claude3Sonnet) == false)
        
        // Premium user should have access to all models
        #expect(premiumConfig.isModelAvailable(.gpt35Turbo) == true)
        #expect(premiumConfig.isModelAvailable(.gpt4o) == true)
        #expect(premiumConfig.isModelAvailable(.claude3Sonnet) == true)
    }
    
    @Test("Test StoryGenerationConfig model selection with validation")
    func testModelSelectionWithValidation() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .free)
        
        // Should successfully select available model
        let success1 = config.selectModel(.gpt35Turbo)
        #expect(success1 == true)
        #expect(config.selectedModel == .gpt35Turbo)
        
        // Should fail to select unavailable model
        let success2 = config.selectModel(.gpt4o)
        #expect(success2 == false)
        #expect(config.selectedModel == .gpt35Turbo) // Should remain unchanged
        
        // Premium should be able to select any model
        var premiumConfig = StoryGenerationConfig(subscriptionTier: .premium)
        let success3 = premiumConfig.selectModel(.claude3Sonnet)
        #expect(success3 == true)
        #expect(premiumConfig.selectedModel == .claude3Sonnet)
    }
    
    @Test("Test StoryGenerationConfig usage progress calculation")
    func testUsageProgressCalculation() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .free)
        
        // Initial progress should be 0
        #expect(config.usageProgress == 0.0)
        
        // Generate one story
        config.incrementStoryCount()
        #expect(config.usageProgress == 1.0/3.0) // 1 of 3
        
        // Generate second story
        config.incrementStoryCount()
        #expect(config.usageProgress == 2.0/3.0) // 2 of 3
        
        // Generate third story (reach limit)
        config.incrementStoryCount()
        #expect(config.usageProgress == 1.0) // 3 of 3 = 100%
    }
    
    @Test("Test StoryGenerationConfig codable conformance")
    func testStoryGenerationConfigCodeable() async throws {
        let originalConfig = StoryGenerationConfig(
            subscriptionTier: .premium,
            selectedModel: .claude3Sonnet,
            storiesGeneratedToday: 5,
            lastResetDate: Date()
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalConfig)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedConfig = try decoder.decode(StoryGenerationConfig.self, from: data)
        
        #expect(decodedConfig.subscriptionTier == originalConfig.subscriptionTier)
        #expect(decodedConfig.selectedModel == originalConfig.selectedModel)
        #expect(decodedConfig.storiesGeneratedToday == originalConfig.storiesGeneratedToday)
        #expect(decodedConfig.dailyStoryLimit == originalConfig.dailyStoryLimit)
    }
    
    @Test("Test StoryGenerationConfig subscription upgrade")
    func testSubscriptionUpgrade() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .free)
        
        // Reach free limit
        for _ in 0..<3 {
            config.incrementStoryCount()
        }
        #expect(config.canGenerateNewStory == false)
        
        // Upgrade to premium
        config.upgradeSubscription(to: .premium)
        
        #expect(config.subscriptionTier == .premium)
        #expect(config.dailyStoryLimit == 10)
        #expect(config.canGenerateNewStory == true) // Should be able to generate again
        #expect(config.storiesRemainingToday == 7) // 10 - 3 existing = 7
    }
    
    @Test("Test StoryGenerationConfig subscription downgrade")
    func testSubscriptionDowngrade() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .premium, selectedModel: .claude3Sonnet)
        
        // Generate some stories
        for _ in 0..<5 {
            config.incrementStoryCount()
        }
        
        // Downgrade to free
        config.downgradeSubscription(to: .free)
        
        #expect(config.subscriptionTier == .free)
        #expect(config.selectedModel == .gpt35Turbo) // Should reset to free default
        #expect(config.dailyStoryLimit == 3)
        #expect(config.canGenerateNewStory == false) // 5 > 3, so should be blocked
    }
    
    @Test("Test StoryGenerationConfig edge cases")
    func testEdgeCases() async throws {
        var config = StoryGenerationConfig(subscriptionTier: .free)
        
        // Test multiple increments at limit
        for _ in 0..<5 { // Try to go over limit
            config.incrementStoryCount()
        }
        #expect(config.storiesGeneratedToday <= config.dailyStoryLimit)
        
        // Test reset with same day date
        let today = Date()
        config.lastResetDate = today
        #expect(config.shouldResetDailyCount == false)
        config.resetDailyCountIfNeeded()
        // Count should not change when resetting on same day
        
        // Test reset with future date (edge case)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        config.lastResetDate = tomorrow
        config.resetDailyCountIfNeeded()
        // Should handle gracefully
        #expect(config.storiesGeneratedToday >= 0)
    }
}
