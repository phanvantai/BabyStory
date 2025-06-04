//
//  AppViewModel.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
import SwiftUI
import StoreKit

/// ViewModel responsible for managing the overall app state, navigation flow, and lifecycle
/// Separates business logic from the view layer following MVVM principles
@MainActor
class AppViewModel: ObservableObject {
    
    // MARK: - Published Properties
    /// Controls whether the onboarding flow should be displayed
    @Published var needsOnboarding: Bool = true
    /// Controls whether the loading screen should be displayed
    @Published var isLoading: Bool = true
    /// Current error state for reactive UI updates
    @Published var currentError: AppError?
    
    // MARK: - Dependencies
    private let userProfileService: UserProfileServiceProtocol
    private let errorManager: ErrorManager
    private let storyGenerationConfigService: StoryGenerationConfigServiceProtocol
    private let storeKitService: StoreKitService
    
    /// The app's current story generation configuration
    @Published var storyGenerationConfig: StoryGenerationConfig?
    
    // MARK: - Initialization
    
    /// Initialize AppViewModel with optional dependency injection for testing
    /// - Parameters:
    ///   - userProfileService: Service for user profile operations
    ///   - errorManager: Manager for centralized error handling
    ///   - storyGenerationConfigService: Service for story generation config operations
    ///   - storeKitService: Service for handling in-app purchases
    init(
        userProfileService: UserProfileServiceProtocol? = nil,
        errorManager: ErrorManager? = nil,
        storyGenerationConfigService: StoryGenerationConfigServiceProtocol? = nil,
        storeKitService: StoreKitService? = nil
    ) {
        self.userProfileService = userProfileService ?? ServiceFactory.shared.createUserProfileService()
        self.errorManager = errorManager ?? ErrorManager()
        self.storyGenerationConfigService = storyGenerationConfigService ?? ServiceFactory.shared.createStoryGenerationConfigService()
        self.storeKitService = storeKitService ?? ServiceFactory.shared.createStoreKitService()
        
        // Load initial config
        do {
            storyGenerationConfig = try self.storyGenerationConfigService.loadConfig()
            // Check and reset daily count if needed
            checkAndResetDailyCount()
        } catch {
            Logger.error("Failed to load story generation config: \(error.localizedDescription)", category: .general)
            storyGenerationConfig = nil
        }
        
        // Observe subscription status changes
        Task {
            // Listen for transaction updates
            for await _ in Transaction.updates {
                await updateSubscriptionStatus()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Loads initial application data and determines whether to show onboarding
    /// or proceed directly to the home screen based on whether a user profile exists
    func loadInitialData() async {
        isLoading = true
        
        do {
            // Load user profile
            let profile = try userProfileService.loadProfile()
            needsOnboarding = profile == nil
            
            // Load story generation config
            storyGenerationConfig = try storyGenerationConfigService.loadConfig()
            
            // Check subscription status
            await checkSubscriptionStatus()
            
            isLoading = false
        } catch {
            Logger.error("Failed to load initial data: \(error.localizedDescription)", category: .general)
            currentError = error as? AppError ?? .dataCorruption
            isLoading = false
        }
    }
    
    /// Handles scene phase changes for app lifecycle management
    /// - Parameters:
    ///   - oldPhase: The previous scene phase
    ///   - newPhase: The new scene phase
    func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) async {
        // Handle scene transitions more gracefully
        if newPhase == .active && oldPhase == .background {
            Logger.info("App became active from background - refreshing data", category: .general)
            
            // App became active from background - refresh data if needed
            if !needsOnboarding && !isLoading {
                // Refresh subscription status when app becomes active
                await checkSubscriptionStatus()
            }
        }
    }
    
    /// Called when onboarding flow is completed successfully
    func onboardingComplete() async {
        Logger.info("Onboarding completed - transitioning to home view", category: .general)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            needsOnboarding = false
        }
    }
    
    /// Handles errors by updating the error state and delegating to ErrorManager
    /// - Parameter error: The AppError to handle
    func handleError(_ error: AppError) {
        Logger.error("AppViewModel handling error: \(error.localizedDescription)", category: .general)
        currentError = error
        errorManager.handleError(error)
    }
    
    /// Clears the current error state
    func clearError() {
        Logger.info("Clearing app error state", category: .general)
        currentError = nil
        errorManager.clearError()
    }
    
    /// Updates the story generation config
    /// - Parameter config: The new config to save
    /// - Returns: True if update was successful, false otherwise
    @discardableResult
    func updateStoryGenerationConfig(_ config: StoryGenerationConfig) -> Bool {
        do {
            try storyGenerationConfigService.saveConfig(config)
            storyGenerationConfig = config
            Logger.info("Updated story generation config - Subscription tier: \(config.subscriptionTier.rawValue), Stories today: \(config.storiesGeneratedToday)/\(config.dailyStoryLimit)", category: .general)
            return true
        } catch {
            Logger.error("Failed to update story generation config: \(error.localizedDescription)", category: .general)
            return false
        }
    }
    
    /// Check and reset daily story count if needed
    func checkAndResetDailyCount() {
        if var config = storyGenerationConfig {
            config.resetDailyCountIfNeeded()
            if updateStoryGenerationConfig(config) {
                Logger.info("Reset daily story count - Stories today: \(config.storiesGeneratedToday)/\(config.dailyStoryLimit)", category: .general)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Check current subscription status
    private func checkSubscriptionStatus() async {
        let status = await storeKitService.getSubscriptionStatus()
        
        // Update subscription tier based on status
        let newTier: SubscriptionTier = status.isActive ? .premium : .free
        
        // Update config if needed
        if var config = storyGenerationConfig {
            let oldTier = config.subscriptionTier
            
            if oldTier != newTier {
                if newTier == .premium {
                    config.upgradeSubscription(to: newTier)
                    Logger.info("Upgraded subscription tier to: \(newTier.rawValue)", category: .general)
                } else {
                    config.downgradeSubscription(to: newTier)
                    Logger.info("Downgraded subscription tier to: \(newTier.rawValue)", category: .general)
                }
                
                // Save the updated config
                if updateStoryGenerationConfig(config) {
                    // Notify observers of the change
                    await MainActor.run {
                        objectWillChange.send()
                    }
                }
            }
        } else {
            // If no config exists, create one with the correct tier
            let newConfig = StoryGenerationConfig(
                subscriptionTier: newTier,
                selectedModel: .gpt35Turbo,
                storiesGeneratedToday: 0,
                lastResetDate: Date()
            )
            
            if updateStoryGenerationConfig(newConfig) {
                Logger.info("Created new config with subscription tier: \(newTier.rawValue)", category: .general)
            }
        }
    }
    
    /// Updates subscription status in response to StoreKit transaction updates
    private func updateSubscriptionStatus() async {
        await checkSubscriptionStatus()
    }
}
