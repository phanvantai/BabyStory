import XCTest
@testable import BabyStory

final class OnboardingViewModelTests: XCTestCase {
    
    var viewModel: OnboardingViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = OnboardingViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.step, 0)
        XCTAssertEqual(viewModel.babyStage, .toddler)
        XCTAssertTrue(viewModel.name.isEmpty)
        XCTAssertTrue(viewModel.interests.isEmpty)
        XCTAssertFalse(viewModel.isPregnancy)
    }
    
    func testValidation() {
        // Initially invalid
        XCTAssertFalse(viewModel.canProceed)
        
        // Add name
        viewModel.name = "Emma"
        XCTAssertFalse(viewModel.canProceed) // Still needs age for non-pregnancy
        
        // Add age (automatically set for toddler)
        XCTAssertNotNil(viewModel.age)
        XCTAssertTrue(viewModel.canProceed)
    }
    
    func testPregnancyValidation() {
        viewModel.updateBabyStage(.pregnancy)
        
        XCTAssertTrue(viewModel.isPregnancy)
        XCTAssertFalse(viewModel.canProceed) // Needs name and parent names
        
        viewModel.name = "Future Baby"
        XCTAssertFalse(viewModel.canProceed) // Still needs parent names
        
        viewModel.parentNames = ["Mom"]
        XCTAssertTrue(viewModel.canProceed)
    }
    
    func testBabyStageUpdate() {
        // Start with toddler
        XCTAssertEqual(viewModel.babyStage, .toddler)
        XCTAssertEqual(viewModel.age, 1)
        
        // Switch to pregnancy
        viewModel.updateBabyStage(.pregnancy)
        XCTAssertTrue(viewModel.isPregnancy)
        XCTAssertNil(viewModel.age)
        XCTAssertFalse(viewModel.parentNames.isEmpty)
        
        // Switch to preschooler
        viewModel.updateBabyStage(.preschooler)
        XCTAssertFalse(viewModel.isPregnancy)
        XCTAssertEqual(viewModel.age, 3)
        XCTAssertTrue(viewModel.parentNames.isEmpty)
    }
    
    func testInterestManagement() {
        let interest = "Animals"
        
        XCTAssertFalse(viewModel.interests.contains(interest))
        
        viewModel.toggleInterest(interest)
        XCTAssertTrue(viewModel.interests.contains(interest))
        
        viewModel.toggleInterest(interest)
        XCTAssertFalse(viewModel.interests.contains(interest))
    }
    
    func testAgeAdjustment() {
        // Test toddler age adjustment
        viewModel.updateBabyStage(.toddler)
        let initialAge = viewModel.age!
        
        viewModel.increaseAge()
        XCTAssertEqual(viewModel.age!, initialAge + 1)
        
        viewModel.decreaseAge()
        XCTAssertEqual(viewModel.age!, initialAge)
        
        // Test fixed age (newborn)
        viewModel.updateBabyStage(.newborn)
        XCTAssertFalse(viewModel.canEditAge)
        XCTAssertEqual(viewModel.age, 0)
    }
}
