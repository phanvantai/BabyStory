//
//  AppViewModel.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
import SwiftUI

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
    
    /// The app's current story generation configuration
    @Published var storyGenerationConfig: StoryGenerationConfig?
    
    // MARK: - Initialization
    
    /// Initialize AppViewModel with optional dependency injection for testing
    /// - Parameters:
    ///   - userProfileService: Service for user profile operations
    ///   - errorManager: Manager for centralized error handling
    ///   - storyGenerationConfigService: Service for story generation config operations
    init(
        userProfileService: UserProfileServiceProtocol? = nil,
        errorManager: ErrorManager? = nil,
        storyGenerationConfigService: StoryGenerationConfigServiceProtocol? = nil
    ) {
        self.userProfileService = userProfileService ?? ServiceFactory.shared.createUserProfileService()
        self.errorManager = errorManager ?? ErrorManager()
        self.storyGenerationConfigService = storyGenerationConfigService ?? ServiceFactory.shared.createStoryGenerationConfigService()
    }
    
    // MARK: - Public Methods
    
    /// Loads initial application data and determines whether to show onboarding
    /// or proceed directly to the home screen based on whether a user profile exists
    func loadInitialData() async {
        Logger.info("App starting - Loading initial data", category: .general)
        
        // Add a small delay to avoid conflicts with app snapshot operations
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 second delay
        
        do {
            // Load user profile
            let profile = try userProfileService.loadProfile()
            
            // Load story generation config
            do {
                var config = try storyGenerationConfigService.loadConfig()
                
                // Reset daily count if needed based on date
                config.resetDailyCountIfNeeded()
                
                // Save config back if day reset occurred
                if config.shouldResetDailyCount {
                    try storyGenerationConfigService.saveConfig(config)
                }
                
                storyGenerationConfig = config
                Logger.info("Loaded story generation config - Subscription tier: \(config.subscriptionTier.rawValue), Stories today: \(config.storiesGeneratedToday)/\(config.dailyStoryLimit)", category: .general)
            } catch {
                Logger.error("Failed to load story generation config: \(error.localizedDescription)", category: .general)
                // Create default config if loading fails
                storyGenerationConfig = StoryGenerationConfig(subscriptionTier: .free)
                try? storyGenerationConfigService.saveConfig(storyGenerationConfig!)
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                needsOnboarding = profile == nil
                isLoading = false
            }
            
            if profile == nil {
                Logger.info("No user profile found - showing onboarding", category: .general)
            } else {
                Logger.info("User profile exists - proceeding to home view", category: .general)
            }
            
        } catch {
            Logger.error("Failed to load initial data: \(error.localizedDescription)", category: .general)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                handleError(.dataCorruption)
                needsOnboarding = true
                isLoading = false
            }
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
                // In a real implementation, this might trigger HomeViewModel.refresh()
                // For now, we just log the action
                Logger.info("Refreshing app data after returning from background", category: .general)
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
}
