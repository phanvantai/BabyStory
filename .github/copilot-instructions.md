# SoftDreams iOS App - Copilot Instructions

## Project Overview
SoftDreams is a SwiftUI iOS application that generates personalized bedtime stories for children. The app uses AI to create custom stories based on the child's profile, interests, and preferences.

## Technical Stack
- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Language**: Swift 5.0
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults
- **Target Devices**: iPhone and iPad
- **Testing Framework**: Swift Testing
- **Development Approach**: Test-Driven Development (TDD)

## Key Features
1. **Onboarding Flow**: Multi-step setup for child profile and preferences
2. **Story Generation**: AI-powered custom story creation
3. **Library**: Save and manage favorite stories
4. **Settings**: Profile management and parental controls
5. **Customization**: Story length, theme, and character options

## Code Style Guidelines

### SwiftUI Best Practices
- Use `@StateObject` for view model initialization
- Use `@ObservedObject` when passing view models between views
- Prefer `NavigationStack` over deprecated `NavigationView`
- Use `.sheet()` for modal presentations
- Implement proper state management with `@State` and `@Published`

### Architecture Patterns
- Follow MVVM pattern consistently
- Keep views lightweight and delegate business logic to ViewModels
- Use `@Published` properties in ViewModels for reactive UI updates
- Implement proper separation of concerns

### Data Management
- Use `UserDefaultsManager` for all data persistence
- Implement proper Codable conformance for data models
- Handle async operations with proper `Task` and `await/async` patterns
- Use `MainActor.run` when updating UI from background threads

## File Naming Conventions
- Views: `[Feature]View.swift` (e.g., `HomeView.swift`)
- ViewModels: `[Feature]ViewModel.swift` (e.g., `HomeViewModel.swift`)
- Models: Descriptive names (e.g., `Story.swift`, `UserProfile.swift`)
- Organize files in logical folders by feature

### Component Organization Rules
- **Feature-specific components**: Components used only within a single feature should be placed in a `Components/` subfolder within that feature's view folder (e.g., `Views/Onboarding/Components/ProfileSummaryRow.swift`)
- **Reusable components**: Components that can be used across multiple features should be placed in `Views/Common/` folder (e.g., `Views/Common/ActionCard.swift`)

## Development Guidelines

### Test-Driven Development (TDD) Requirements
**ALL new features and code changes MUST follow TDD practices:**

1. **Red Phase**: Write failing tests first
   - Create comprehensive test cases that define the expected behavior
   - Tests should fail initially (red state)
   - Cover edge cases, error conditions, and happy paths

2. **Green Phase**: Write minimal code to make tests pass
   - Implement only the code necessary to pass the tests
   - Focus on functionality, not optimization

3. **Refactor Phase**: Improve code while maintaining test coverage
   - Clean up code structure and design
   - Ensure all tests continue to pass
   - Optimize performance if needed

### Testing Standards
- **Minimum 80% code coverage** for all new code
- **Unit tests** for all ViewModels, Models, and Services
- **Integration tests** for data persistence and API interactions
- **UI tests** for critical user flows (onboarding, story generation)
- **Protocol compliance tests** for all protocol implementations

### Test Naming Convention
- Test files: `[Feature/Component]Tests.swift`
- Test methods: Use descriptive names that explain the scenario
- Example: `testOnboardingViewModel_WhenValidProfileData_ShouldSaveSuccessfully()`

### Test Organization
- Place test files in `SoftDreamsTests/` folder
- Mirror the main app folder structure
- Group related tests in the same file
- Use `@Test` attribute for Swift Testing framework
- **All new mocks for testing should be placed in `SoftDreamsTests/Mocks/` folder for consistency**

### When Adding New Features:
1. **WRITE TESTS FIRST** (TDD Red Phase)
   - Create test file in appropriate `SoftDreamsTests/` subfolder
   - Write failing tests that define expected behavior
   - Test both success and failure scenarios
2. **Implement minimal code** to pass tests (TDD Green Phase)
3. **Refactor and optimize** while maintaining test coverage (TDD Refactor Phase)
4. Create appropriate models in `Models/` folder
5. Implement ViewModels with `@Published` properties
6. Create SwiftUI views following existing patterns
7. Update `UserDefaultsManager` if persistence is needed
8. Follow the established navigation patterns
9. Place feature-specific components in `Views/[Feature]/Components/` folder
10. Only add components to `Views/Common/` if they are truly reusable across multiple features

### When Modifying Existing Code:
- **WRITE TESTS FIRST** if tests don't exist for the code being modified
- Ensure existing tests pass before making changes
- Add new tests for any new functionality or edge cases
- Maintain consistency with existing code style
- Update related ViewModels when changing data models
- Ensure proper error handling for async operations
- Test onboarding flow after profile-related changes
- Verify test coverage remains above 80%

### UI/UX Considerations:
- Maintain child-friendly design patterns
- Use appropriate button styles (`.borderedProminent`, `.bordered`)
- Implement proper accessibility features
- Consider parental control requirements

## Common Patterns

### View Model Pattern:
```swift
class FeatureViewModel: ObservableObject {
    @Published var property: Type = defaultValue
    
    func performAction() {
        // Business logic here
    }
}
```

### Async Story Generation:
```swift
Task {
    await viewModel.generateStory(profile: profile, options: options)
    // Update UI state
}
```

### Navigation:
```swift
.navigationDestination(isPresented: $showView) {
    DestinationView(viewModel: viewModel)
}
```

## Testing Considerations
- Test onboarding flow completion
- Verify story generation and saving functionality
- Test data persistence across app launches
- Validate parental control features
- **REMEMBER**: Always follow TDD - write tests before implementing features
- Maintain comprehensive test coverage for all business logic
- Test error handling and edge cases thoroughly
- Use Swift Testing framework with `@Test` attributes
- Mock external dependencies in unit tests

## Future Development Notes
- Story generation currently uses placeholder/mock implementation
- Progress tracking feature is marked as TODO
- Voice narration is planned but not implemented
- Image generation for stories is placeholder

## Bundle Identifier
`com.randomtech.SoftDreams`

## Development Team
K6GZTHQ9Z5

When working on this project, prioritize child safety, intuitive UI design, and maintainable code architecture following the established MVVM patterns.