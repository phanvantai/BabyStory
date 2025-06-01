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

### When Adding New Features:
1. Create appropriate models in `Models/` folder
2. Implement ViewModels with `@Published` properties
3. Create SwiftUI views following existing patterns
4. Update `UserDefaultsManager` if persistence is needed
5. Follow the established navigation patterns
6. Place feature-specific components in `Views/[Feature]/Components/` folder
7. Only add components to `Views/Common/` if they are truly reusable across multiple features

### When Modifying Existing Code:
- Maintain consistency with existing code style
- Update related ViewModels when changing data models
- Ensure proper error handling for async operations
- Test onboarding flow after profile-related changes

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