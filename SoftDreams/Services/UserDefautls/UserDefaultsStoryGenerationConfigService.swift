//
//  UserDefaultsStoryGenerationConfigService.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 4/6/25.
//

import Foundation

/// Protocol for the StoryGenerationConfig persistence service
protocol StoryGenerationConfigServiceProtocol {
    /// Save the StoryGenerationConfig to storage
    /// - Parameter config: The config to save
    /// - Throws: An error if saving fails
    func saveConfig(_ config: StoryGenerationConfig) throws
    
    /// Load the current StoryGenerationConfig from storage
    /// - Returns: The stored config, or a default config if none exists
    /// - Throws: An error if loading fails
    func loadConfig() throws -> StoryGenerationConfig
    
    /// Reset the StoryGenerationConfig to default values
    /// - Throws: An error if the reset fails
    func resetConfig() throws
    
    /// Check if a configuration exists in storage
    /// - Returns: true if a config exists, false otherwise
    func configExists() -> Bool
}

/// UserDefaults implementation of StoryGenerationConfigServiceProtocol
class UserDefaultsStoryGenerationConfigService: StoryGenerationConfigServiceProtocol {
    // MARK: - Properties
    var defaults: UserDefaults { return UserDefaults.standard }
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Allow initialization for subclassing in tests
    init() {}
    
    // MARK: - StoryGenerationConfigServiceProtocol Implementation
    
    func saveConfig(_ config: StoryGenerationConfig) throws {
        do {
            let data = try encoder.encode(config)
            defaults.set(data, forKey: StorageKeys.storyGenerationConfig)
        } catch {
            Logger.error("Failed to save StoryGenerationConfig: \(error.localizedDescription)", category: .general)
            throw AppError.dataSaveFailed
        }
    }
    
    func loadConfig() throws -> StoryGenerationConfig {
        guard let data = defaults.data(forKey: StorageKeys.storyGenerationConfig) else {
            // Return default config if none exists
            return createDefaultConfig()
        }
        
        do {
            return try decoder.decode(StoryGenerationConfig.self, from: data)
        } catch {
            Logger.error("Failed to decode StoryGenerationConfig: \(error.localizedDescription)", category: .general)
            throw AppError.dataCorruption
        }
    }
    
    func resetConfig() throws {
        defaults.removeObject(forKey: StorageKeys.storyGenerationConfig)
    }
    
    func configExists() -> Bool {
        return defaults.data(forKey: StorageKeys.storyGenerationConfig) != nil
    }
    
    // MARK: - Private Helper Methods
    
    private func createDefaultConfig() -> StoryGenerationConfig {
        // Start with free tier and default model
        return StoryGenerationConfig(
            subscriptionTier: .free,
            selectedModel: .gpt35Turbo,
            storiesGeneratedToday: 0,
            lastResetDate: Date()
        )
    }
}
