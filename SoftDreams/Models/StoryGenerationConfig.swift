//
//  StoryGenerationConfig.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation

struct StoryGenerationConfig: Codable, Equatable {
    /// Current subscription tier
    var subscriptionTier: SubscriptionTier
    
    /// Currently selected AI model for story generation
    var selectedModel: AIModel
    
    /// Number of stories generated today
    var storiesGeneratedToday: Int
    
    /// Date when the daily count was last reset
    var lastResetDate: Date
    
    /// Daily story generation limit based on subscription tier
    var dailyStoryLimit: Int {
        return subscriptionTier.dailyStoryLimit
    }
    
    /// Whether user can generate a new story today (call resetDailyCountIfNeeded() before using)
    var canGenerateNewStory: Bool {
        return storiesGeneratedToday < dailyStoryLimit
    }
    
    /// Number of stories remaining today (call resetDailyCountIfNeeded() before using)
    var storiesRemainingToday: Int {
        return max(0, dailyStoryLimit - storiesGeneratedToday)
    }
    
    /// Progress percentage of daily usage (0.0 to 1.0) (call resetDailyCountIfNeeded() before using)
    var usageProgress: Double {
        guard dailyStoryLimit > 0 else { return 0.0 }
        return min(1.0, Double(storiesGeneratedToday) / Double(dailyStoryLimit))
    }
    
    /// Whether daily count should be reset based on date
    var shouldResetDailyCount: Bool {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the start of day for both dates
        let lastResetStartOfDay = calendar.startOfDay(for: lastResetDate)
        let todayStartOfDay = calendar.startOfDay(for: today)
        
        // Compare the start of day dates
        return lastResetStartOfDay != todayStartOfDay
    }
    
    // MARK: - Initialization
    
    init(subscriptionTier: SubscriptionTier, 
         selectedModel: AIModel? = nil, 
         storiesGeneratedToday: Int = 0, 
         lastResetDate: Date? = nil) {
        self.subscriptionTier = subscriptionTier
        self.selectedModel = selectedModel ?? subscriptionTier.defaultModel
        self.storiesGeneratedToday = storiesGeneratedToday
        self.lastResetDate = lastResetDate ?? Date()
    }
    
    // MARK: - Story Generation Management
    
    /// Increment the daily story count
    mutating func incrementStoryCount() {
        resetDailyCountIfNeeded()
        if storiesGeneratedToday < dailyStoryLimit {
            storiesGeneratedToday += 1
        }
    }
    
    /// Reset daily count if needed (called automatically by computed properties)
    mutating func resetDailyCountIfNeeded() {
        if shouldResetDailyCount {
            storiesGeneratedToday = 0
            lastResetDate = Date()
        }
    }
    
    // MARK: - Model Management
    
    /// Check if a specific AI model is available for current subscription tier
    func isModelAvailable(_ model: AIModel) -> Bool {
        return subscriptionTier.availableModels.contains(model)
    }
    
    /// Attempt to select an AI model, returns true if successful
    mutating func selectModel(_ model: AIModel) -> Bool {
        guard isModelAvailable(model) else {
            return false
        }
        selectedModel = model
        return true
    }
    
    // MARK: - Subscription Management
    
    /// Upgrade subscription tier
    mutating func upgradeSubscription(to newTier: SubscriptionTier) {
        subscriptionTier = newTier
        
        // If current model is not available in new tier, reset to default
        if !isModelAvailable(selectedModel) {
            selectedModel = newTier.defaultModel
        }
    }
    
    /// Downgrade subscription tier
    mutating func downgradeSubscription(to newTier: SubscriptionTier) {
        subscriptionTier = newTier
        
        // Reset to default model for new tier
        selectedModel = newTier.defaultModel
    }
}
