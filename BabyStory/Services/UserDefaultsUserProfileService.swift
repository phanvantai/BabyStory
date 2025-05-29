import Foundation

// MARK: - UserDefaults User Profile Service
/// UserDefaults implementation of UserProfileServiceProtocol
class UserDefaultsUserProfileService: UserProfileServiceProtocol {
    
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - UserProfileServiceProtocol Implementation
    
    func saveProfile(_ profile: UserProfile) throws {
        do {
            let data = try encoder.encode(profile)
            defaults.set(data, forKey: StorageKeys.userProfile)
        } catch {
            throw AppError.profileSaveFailed
        }
    }
    
    func loadProfile() throws -> UserProfile? {
        guard let data = defaults.data(forKey: StorageKeys.userProfile) else { 
            return nil 
        }
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            throw AppError.dataCorruption
        }
    }
    
    func deleteProfile() throws {
        defaults.removeObject(forKey: StorageKeys.userProfile)
    }
    
    func profileExists() -> Bool {
        return defaults.data(forKey: StorageKeys.userProfile) != nil
    }
    
    func updateProfile(_ updates: (inout UserProfile) -> Void) throws {
        guard var profile = try loadProfile() else {
          throw AppError.invalidProfile
        }
        updates(&profile)
        try saveProfile(profile)
    }
}
