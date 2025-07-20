# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is an iOS SwiftUI application built with Xcode. Use these commands:

```bash
# Build the project
xcodebuild -project SoftDreams.xcodeproj -scheme SoftDreams build

# Run tests
xcodebuild -project SoftDreams.xcodeproj -scheme SoftDreams test -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'

# Alternative: Use Xcode IDE
# Build: ⌘ + B
# Run: ⌘ + R  
# Test: ⌘ + U
```

## High-Level Architecture

### Core Architecture Pattern

- **MVVM (Model-View-ViewModel)** with SwiftUI
- **Protocol-based dependency injection** via ServiceFactory
- **Fast implementation approach** with optional testing (per Copilot instructions)

### Key Architectural Components

**ServiceFactory Pattern**: Centralized service creation and dependency injection

- All services created through `ServiceFactory.shared`
- Easy switching between implementations (UserDefaults, CoreData, etc.)
- Protocol-based design for testability

**Data Persistence Strategy**:

- **UserDefaults**: User profiles, settings, themes, story generation config
- **CoreData**: Story library (persistent stories)
- Services follow specific protocols for consistent interfaces

**AI Integration Architecture**:

- Multiple AI providers: OpenAI GPT (3.5/4) and Anthropic Claude
- Service selection based on subscription tier and user preference
- API keys configured via build settings or environment variables

### Critical Code Organization

**Component Organization Rules** (from Copilot instructions):

- Feature-specific components: `Views/[Feature]/Components/`
- Reusable components: `Views/Common/`
- This distinction is crucial for maintainability

**Service Layer Structure**:

- Protocol definitions in `Protocols/`
- Implementations in `Services/` with categorical organization
- UserDefaults services use `StorageKeys.swift` for key management

### State Management Pattern

- ViewModels use `@Published` properties for reactive UI
- App-wide state managed by `AppViewModel` (injected via SceneDelegate)
- Theme and language management via singleton managers

### Subscription & Usage Model

- Freemium: 3 stories/day (free) vs 20 stories/day (premium)
- Usage tracking with daily reset via `StoryGenerationConfig`
- StoreKit integration for subscription management

## API Configuration

The app requires API keys for AI services, configured in `Config/APIConfig.swift`:

```swift
// Required environment variables or build settings:
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key (optional)
ANTHROPIC_API_BASE_URL=https://api.anthropic.com/v1 (optional)
OPENAI_API_BASE_URL=https://api.openai.com/v1 (optional)
```

## Development Approach

**Fast Implementation Philosophy** (per Copilot instructions):

1. Feature-first rapid development
2. Manual testing during development
3. Add automated tests for critical paths when stability needed
4. Iterative improvement based on feedback

**Testing Strategy**:

- Swift Testing framework with `@Test` attributes
- Mock services in `SoftDreamsTests/Mocks/`
- Protocol-based architecture enables easy testing
- Current focus: Core functionality over comprehensive test coverage

## Key Technical Details

**Notification System**:

- Story time reminders with customizable scheduling
- Pregnancy milestone notifications with actionable responses
- Proper permission handling and fallback UI

**Localization**:

- English and Vietnamese support
- Dynamic language switching without restart
- Localized story generation and UI

**Multi-Platform Support**:

- iPhone and iPad responsive design
- iOS 17.0+ minimum deployment target
- Universal app with proper layout adaptation

**Data Models**:

- User profiles support pregnancy through preschooler stages
- Auto-progression of baby milestones
- Story customization with themes, length, characters

## Critical Implementation Notes

- **ServiceFactory** is the entry point for all service creation
- **AppViewModel** manages app-wide state and is injected via SceneDelegate
- **Never assume API keys exist** - always check availability in ServiceFactory
- **Component placement** follows strict rules - respect the feature/common distinction
- **Manual testing preferred** during development for speed
- **Profile updates** trigger automatic milestone progression and notifications
