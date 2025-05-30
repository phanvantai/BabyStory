import XCTest
@testable import BabyStory

class StorageManagerTests: XCTestCase {
    
    var storageManager: StorageManager!
    var testProfile: UserProfile!
    var testStories: [Story]!
    
    override func setUpWithError() throws {
        // Create a test storage manager with a mock storage
        storageManager = StorageManager(customStorage: MockStorage())
        
        // Create test data
        testProfile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["Animals", "Colors"],
            storyTime: Date(),
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date())
        )
        
        testStories = [
            Story(
                id: UUID(),
                title: "Test Story 1",
                content: "This is a test story",
                length: .short,
                theme: "Adventure",
                characters: ["Test Character"],
                createdAt: Date(),
                isFavorite: false
            ),
            Story(
                id: UUID(),
                title: "Test Story 2",
                content: "This is another test story",
                length: .medium,
                theme: "Magic",
                characters: ["Magic Character"],
                createdAt: Date(),
                isFavorite: true
            )
        ]
    }
    
    override func tearDownWithError() throws {
        storageManager = nil
        testProfile = nil
        testStories = nil
    }
    
    func testProfileSaveAndLoad() throws {
        // Test saving profile
        try storageManager.saveProfile(testProfile)
        
        // Test loading profile
        let loadedProfile = try storageManager.loadProfile()
        XCTAssertNotNil(loadedProfile)
        XCTAssertEqual(loadedProfile?.name, testProfile.name)
        XCTAssertEqual(loadedProfile?.babyStage, testProfile.babyStage)
    }
    
    func testStoriesSaveAndLoad() throws {
        // Test saving stories
        try storageManager.saveStories(testStories)
        
        // Test loading stories
        let loadedStories = try storageManager.loadStories()
        XCTAssertEqual(loadedStories.count, testStories.count)
        XCTAssertEqual(loadedStories[0].title, testStories[0].title)
        XCTAssertEqual(loadedStories[1].title, testStories[1].title)
    }
    
    func testSingleStorySave() throws {
        // Save initial stories
        try storageManager.saveStories([testStories[0]])
        
        // Add a new story
        try storageManager.saveStory(testStories[1])
        
        // Verify both stories are saved
        let loadedStories = try storageManager.loadStories()
        XCTAssertEqual(loadedStories.count, 2)
    }
    
    func testToggleFavorite() throws {
        // Save stories
        try storageManager.saveStories(testStories)
        
        // Toggle favorite for first story
        let storyId = testStories[0].id
        try storageManager.toggleStoryFavorite(withId: storyId)
        
        // Verify favorite status changed
        let loadedStories = try storageManager.loadStories()
        let toggledStory = loadedStories.first { $0.id == storyId }
        XCTAssertNotNil(toggledStory)
        XCTAssertTrue(toggledStory!.isFavorite)
    }
    
    func testDeleteStory() throws {
        // Save stories
        try storageManager.saveStories(testStories)
        
        // Delete first story
        try storageManager.deleteStory(withId: testStories[0].id)
        
        // Verify story is deleted
        let loadedStories = try storageManager.loadStories()
        XCTAssertEqual(loadedStories.count, 1)
        XCTAssertEqual(loadedStories[0].id, testStories[1].id)
    }
    
    func testThemeSaveAndLoad() throws {
        // Test saving theme
        storageManager.saveTheme(.dark)
        
        // Test loading theme
        let loadedTheme = storageManager.loadTheme()
        XCTAssertEqual(loadedTheme, .dark)
    }
    
    func testSettingsSaveAndLoad() throws {
        // Test narration setting
        try storageManager.saveNarrationEnabled(false)
        let narrationEnabled = storageManager.loadNarrationEnabled()
        XCTAssertFalse(narrationEnabled)
        
        // Test parental lock setting
        try storageManager.saveParentalLockEnabled(true)
        let parentalLockEnabled = storageManager.loadParentalLockEnabled()
        XCTAssertTrue(parentalLockEnabled)
        
        // Test parental passcode
        try storageManager.saveParentalPasscode("1234")
        let passcode = storageManager.loadParentalPasscode()
        XCTAssertEqual(passcode, "1234")
    }
    
    func testConvenienceProperties() throws {
        // Save test data
        try storageManager.saveProfile(testProfile)
        try storageManager.saveStories(testStories)
        
        // Test convenience properties
        XCTAssertTrue(storageManager.hasCompletedOnboarding)
        XCTAssertEqual(storageManager.totalStoriesCount, 2)
        XCTAssertEqual(storageManager.favoriteStoriesCount, 1)
    }
    
    func testDataExportImport() throws {
        // Save test data
        try storageManager.saveProfile(testProfile)
        try storageManager.saveStories(testStories)
        storageManager.saveTheme(.light)
        
        // Export data
        let exportedData = try storageManager.exportData()
        
        // Clear data
        try storageManager.clearAllData()
        
        // Verify data is cleared
        XCTAssertNil(try storageManager.loadProfile())
        XCTAssertEqual(try storageManager.loadStories().count, 0)
        
        // Import data
        try storageManager.importData(exportedData)
        
        // Verify data is restored
        let restoredProfile = try storageManager.loadProfile()
        XCTAssertNotNil(restoredProfile)
        XCTAssertEqual(restoredProfile?.name, testProfile.name)
        
        let restoredStories = try storageManager.loadStories()
        XCTAssertEqual(restoredStories.count, testStories.count)
        
        let restoredTheme = storageManager.loadTheme()
        XCTAssertEqual(restoredTheme, .light)
    }
}

// MARK: - Mock Storage for Testing
class MockStorage: StorageProtocol {
    private var profileData: UserProfile?
    private var storiesData: [Story] = []
    private var themeData: ThemeMode = .system
    private var settings: [String: Any] = [:]
    
    func saveProfile(_ profile: UserProfile) throws {
        profileData = profile
    }
    
    func loadProfile() throws -> UserProfile? {
        return profileData
    }
    
    func saveStories(_ stories: [Story]) throws {
        storiesData = stories
    }
    
    func loadStories() throws -> [Story] {
        return storiesData
    }
    
    func saveTheme(_ theme: ThemeMode) {
        themeData = theme
    }
    
    func loadTheme() -> ThemeMode {
        return themeData
    }
    
    func saveSetting<T: Codable>(_ value: T, forKey key: String) throws {
        settings[key] = value
    }
    
    func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        return settings[key] as? T
    }
    
    func removeSetting(forKey key: String) {
        settings.removeValue(forKey: key)
    }
    
    func clearAllData() throws {
        profileData = nil
        storiesData = []
        themeData = .system
        settings = [:]
    }
    
    func exportData() throws -> Data {
        let exportData = MockExportData(
            profile: profileData,
            stories: storiesData,
            theme: themeData,
            settings: settings
        )
        return try JSONEncoder().encode(exportData)
    }
    
    func importData(_ data: Data) throws {
        let importData = try JSONDecoder().decode(MockExportData.self, from: data)
        profileData = importData.profile
        storiesData = importData.stories
        themeData = importData.theme
        settings = importData.settings
    }
}

// MARK: - Mock Export Data Structure
struct MockExportData: Codable {
    let profile: UserProfile?
    let stories: [Story]
    let theme: ThemeMode
    let settings: [String: AnyCodable]
    
    init(profile: UserProfile?, stories: [Story], theme: ThemeMode, settings: [String: Any]) {
        self.profile = profile
        self.stories = stories
        self.theme = theme
        self.settings = settings.mapValues { AnyCodable($0) }
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unsupported type"))
        }
    }
}
