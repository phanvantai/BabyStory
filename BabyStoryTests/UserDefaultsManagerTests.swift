import XCTest
@testable import BabyStory

final class UserDefaultsManagerTests: XCTestCase {
    
    var manager: UserDefaultsManager!
    var testSuiteName = "TestUserDefaults"
    
    override func setUp() {
        super.setUp()
        // Use a separate UserDefaults suite for testing
        UserDefaults().removePersistentDomain(forName: testSuiteName)
        manager = UserDefaultsManager()
    }
    
    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: testSuiteName)
        manager = nil
        super.tearDown()
    }
    
    func testProfileSaveAndLoad() throws {
        let profile = UserProfile(
            name: "Test Baby",
            babyStage: .toddler,
            interests: ["Animals", "Colors"],
            storyTime: Date(),
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date())
        )
        
        // Test saving
        XCTAssertNoThrow(try manager.saveProfile(profile))
        
        // Test loading
        let loadedProfile = try manager.loadProfile()
        XCTAssertNotNil(loadedProfile)
        XCTAssertEqual(loadedProfile?.name, "Test Baby")
        XCTAssertEqual(loadedProfile?.babyStage, .toddler)
        XCTAssertEqual(loadedProfile?.interests.count, 2)
    }
    
    func testStorySaveAndLoad() throws {
        let story = Story(
            id: UUID(),
            title: "Test Story",
            content: "Once upon a time...",
            date: Date(),
            isFavorite: false
        )
        
        let stories = [story]
        
        // Test saving
        XCTAssertNoThrow(try manager.saveStories(stories))
        
        // Test loading
        let loadedStories = try manager.loadStories()
        XCTAssertEqual(loadedStories.count, 1)
        XCTAssertEqual(loadedStories.first?.title, "Test Story")
    }
    
    func testThemeSaveAndLoad() {
        let theme = ThemeMode.dark
        
        // Test saving
        manager.saveTheme(theme)
        
        // Test loading
        let loadedTheme = manager.loadTheme()
        XCTAssertEqual(loadedTheme, .dark)
    }
    
    func testEmptyStoryLoad() throws {
        // Test loading when no stories are saved
        let stories = try manager.loadStories()
        XCTAssertTrue(stories.isEmpty)
    }
    
    func testEmptyProfileLoad() throws {
        // Test loading when no profile is saved
        let profile = try manager.loadProfile()
        XCTAssertNil(profile)
    }
}
