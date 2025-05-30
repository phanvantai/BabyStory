import XCTest
@testable import BabyStory

final class UserProfileTests: XCTestCase {
    
    func testUserProfileCreation() {
        let profile = UserProfile(
            name: "Emma",
            babyStage: .toddler,
            interests: ["Animals", "Colors"],
            storyTime: Date(),
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: Date())
        )
        
        XCTAssertEqual(profile.name, "Emma")
        XCTAssertEqual(profile.babyStage, .toddler)
        XCTAssertEqual(profile.interests.count, 2)
        XCTAssertFalse(profile.isPregnancy)
        XCTAssertNotNil(profile.currentAge)
    }
    
    func testPregnancyProfile() {
        let profile = UserProfile(
            name: "Future Baby",
            babyStage: .pregnancy,
            interests: ["Gentle Stories"],
            storyTime: Date(),
            parentNames: ["Mom", "Dad"]
        )
        
        XCTAssertTrue(profile.isPregnancy)
        XCTAssertNil(profile.currentAge)
        XCTAssertEqual(profile.parentNames.count, 2)
        XCTAssertEqual(profile.displayName, "Baby Future Baby")
    }
    
    func testStoryContext() {
        let toddlerProfile = UserProfile(
            name: "Emma",
            age: 2,
            babyStage: .toddler,
            interests: ["Animals"],
            storyTime: Date()
        )
        
        let context = toddlerProfile.storyContext
        XCTAssertTrue(context.contains("Emma"))
        XCTAssertTrue(context.contains("adventure"))
    }
    
    func testWelcomeSubtitle() {
        let profile = UserProfile(
            name: "Emma",
            age: 3,
            babyStage: .preschooler,
            interests: ["Magic"],
            storyTime: Date()
        )
        
        let subtitle = profile.getWelcomeSubtitle()
        XCTAssertFalse(subtitle.isEmpty)
        XCTAssertTrue(subtitle.contains("!"))
    }
}
