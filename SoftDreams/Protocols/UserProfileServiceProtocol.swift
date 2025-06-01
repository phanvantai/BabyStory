import Foundation

// MARK: - User Profile Service Protocol
/// Handles user profile data persistence and management
protocol UserProfileServiceProtocol {
  /// Save a user profile to storage
  /// - Parameter profile: The user profile to save
  /// - Throws: Storage error if save operation fails
  func saveProfile(_ profile: UserProfile) throws
  
  /// Load the current user profile from storage
  /// - Returns: The user profile if it exists, nil otherwise
  /// - Throws: Storage error if load operation fails
  func loadProfile() throws -> UserProfile?
  
  /// Load all user profiles from storage
  /// - Returns: An array of user profiles
  /// - Throws: Storage error if load operation fails
  //   func loadAllProfiles() throws -> [UserProfile]
  
  /// Delete the current user profile from storage
  /// - Throws: Storage error if delete operation fails
  //  func deleteProfile() throws
  
  /// Check if a user profile exists in storage
  /// - Returns: true if profile exists, false otherwise
  //  func profileExists() -> Bool
  
  /// Update specific profile fields without replacing the entire profile
  /// - Parameter updates: A closure that modifies the profile
  /// - Throws: Storage error if update operation fails
  func updateProfile(_ updates: (inout UserProfile) -> Void) throws
}
