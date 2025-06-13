# What's New Feature Implementation Guide

## Overview

This guide provides a step-by-step implementation plan for adding a "What's New" popup feature to the SoftDreams iOS app. The popup will only show when a new app version contains significant features worth highlighting to users.

## Implementation Strategy

- **Approach**: Local JSON configuration with hardcoded fallback
- **Display Logic**: Only show if `hasSignificantFeatures` is true
- **Version Tracking**: Compare current app version with stored "last seen version"
- **Architecture**: Follow existing MVVM pattern with service layer

---

## Step 1: Create Data Models

### Files to Create

- `Models/WhatsNew.swift`

### Tasks

1. Create `WhatsNewItem` struct with:
   - `version: String`
   - `hasSignificantFeatures: Bool`
   - `features: [WhatsNewFeature]`
   - `releaseDate: Date?` (optional)

2. Create `WhatsNewFeature` struct with:
   - `title: String`
   - `description: String`
   - `icon: String?` (SF Symbol name)
   - `isHighlight: Bool`

3. Add `Codable` conformance for JSON parsing
4. Add convenience initializers and computed properties as needed

---

## Step 2: Create Service Protocol

### Files to Create

- `Protocols/WhatsNewServiceProtocol.swift`

### Tasks

1. Define protocol with methods:
   - `func shouldShowWhatsNew() -> Bool`
   - `func getWhatsNewContent() -> WhatsNewItem?`
   - `func markWhatsNewAsShown()`
   - `func getCurrentAppVersion() -> String`
   - `func getLastSeenVersion() -> String?`

2. Add documentation comments

---

## Step 3: Implement WhatsNew Service

### Files to Create

- `Services/WhatsNew/WhatsNewService.swift`
- `Services/WhatsNew/WhatsNewManager.swift` (helper class)

### Tasks

1. **WhatsNewService Implementation:**
   - Implement `WhatsNewServiceProtocol`
   - Add dependency on `StorageManagerProtocol` (UserDefaults)
   - Implement version comparison logic
   - Add hardcoded content as fallback

2. **WhatsNewManager Implementation:**
   - Handle JSON file loading and parsing
   - Provide content retrieval methods
   - Handle error cases gracefully

3. **Version Comparison Logic:**
   - Compare semantic versions (e.g., "2.1.0" vs "2.0.1")
   - Handle edge cases (first install, version downgrades)
   - Use proper version string comparison

4. **UserDefaults Keys:**
   - `lastSeenAppVersion`
   - `whatsNewShownForVersion`

---

## Step 4: Create JSON Configuration

### Files to Create

- `Resources/WhatsNew.json`

### Tasks

1. Create JSON structure with version entries
2. Add sample content for current and future versions
3. Ensure proper JSON validation

### Sample JSON Structure

```json
{
  "versions": [
    {
      "version": "2.1.0",
      "hasSignificantFeatures": true,
      "releaseDate": "2025-06-13",
      "features": [
        {
          "title": "New Story Themes",
          "description": "Explore adventure and mystery themes for more exciting bedtime stories",
          "icon": "book.fill",
          "isHighlight": true
        },
        {
          "title": "Enhanced Library",
          "description": "Better organization and search for your saved stories",
          "icon": "books.vertical.fill",
          "isHighlight": false
        }
      ]
    },
    {
      "version": "2.0.1",
      "hasSignificantFeatures": false,
      "features": []
    }
  ]
}
```

---

## Step 5: Create SwiftUI View

### Files to Create

- `Views/Common/WhatsNewView.swift`
- `Views/Common/Components/WhatsNewFeatureRow.swift`

### Tasks

1. **WhatsNewView:**
   - Modal presentation with sheet styling
   - Header with app icon and "What's New" title
   - Scrollable list of features
   - "Continue" button at bottom
   - Proper spacing and child-friendly design

2. **WhatsNewFeatureRow:**
   - Icon, title, and description layout
   - Highlight styling for featured items
   - Accessibility support

3. **Design Guidelines:**
   - Follow existing app design patterns
   - Use child-friendly colors and fonts
   - Implement smooth animations
   - Add proper accessibility labels

---

## Step 6: Create ViewModel

### Files to Create

- `ViewModels/WhatsNewViewModel.swift`

### Tasks

1. Create `WhatsNewViewModel: ObservableObject`
2. Add `@Published` properties:
   - `whatsNewItem: WhatsNewItem?`
   - `isLoading: Bool`
   - `hasError: Bool`

3. Implement methods:
   - `loadWhatsNewContent()`
   - `markAsShown()`
   - `dismissWhatsNew()`

4. Add dependency injection for `WhatsNewServiceProtocol`

---

## Step 7: Integrate with ServiceFactory

### Files to Modify

- `Services/ServiceFactory.swift`

### Tasks

1. Add `WhatsNewService` registration
2. Follow existing service registration patterns
3. Ensure proper dependency injection

---

## Step 8: Enhance AppViewModel

### Files to Modify

- `ViewModels/AppViewModel.swift`

### Tasks

1. Add `@Published var shouldShowWhatsNew: Bool = false`
2. Add `WhatsNewServiceProtocol` dependency
3. Implement version checking logic in app initialization
4. Add method to handle what's new presentation

### Integration Points

- Check for what's new after app launch
- Coordinate with existing onboarding flow
- Handle timing for popup display

---

## Step 9: Integrate with Main App Flow

### Files to Modify

- `AppView.swift` or main container view
- Potentially `Views/Home/HomeView.swift`

### Tasks

1. Add `.sheet()` modifier for WhatsNewView presentation
2. Bind to AppViewModel's `shouldShowWhatsNew` state
3. Ensure proper presentation timing:
   - After onboarding for new users
   - On app launch for existing users
   - Not during story generation or other critical flows

---

## Step 10: Add Localization Support

### Files to Create/Modify

- `Resources/en.lproj/Localizable.strings`
- `Resources/vi.lproj/Localizable.strings`

### Tasks

1. Add localized strings for:
   - "What's New" title
   - "Continue" button
   - Feature titles and descriptions
   - Error messages

2. Update WhatsNewView to use localized strings
3. Consider localized JSON files for content

---

## Step 11: Add Unit Tests (Optional)

### Files to Create

- `SoftDreamsTests/Services/WhatsNewServiceTests.swift`
- `SoftDreamsTests/ViewModels/WhatsNewViewModelTests.swift`
- `SoftDreamsTests/Mocks/MockWhatsNewService.swift`

### Tasks

1. Test version comparison logic
2. Test JSON parsing and error handling
3. Test ViewModel state management
4. Test service integration
5. Mock external dependencies

---

## Step 12: Testing and Validation

### Manual Testing Checklist

- [ ] Fresh app install shows what's new for current version
- [ ] App update shows what's new only if `hasSignificantFeatures` is true
- [ ] Popup doesn't show again after dismissal
- [ ] Version comparison works correctly
- [ ] JSON parsing handles malformed data gracefully
- [ ] Localization works for both languages
- [ ] Accessibility features work properly
- [ ] Child-friendly design is maintained

### Edge Cases to Test

- [ ] First app install
- [ ] Version downgrade (rare but possible)
- [ ] Corrupted UserDefaults data
- [ ] Missing or invalid JSON file
- [ ] Network connectivity issues (future remote config)

---

## Future Enhancements

### Phase 2 Features

1. **Remote Configuration:**
   - API endpoint for what's new content
   - Fallback to local content
   - Content caching strategy

2. **Advanced Features:**
   - Preview images for features
   - Video demonstrations
   - Interactive onboarding for new features
   - Analytics tracking

3. **Content Management:**
   - Admin panel for content management
   - A/B testing for different presentations
   - Personalized what's new based on user profile

---

## Implementation Notes

### Development Approach

- Follow the "Fast Implementation" approach from coding guidelines
- Implement core functionality first, enhance later
- Test manually during development
- Add automated tests for critical business logic

### Key Considerations

- Maintain child-friendly UI design
- Ensure accessibility compliance
- Follow existing MVVM patterns
- Use established service architecture
- Support existing localization

### Estimated Timeline

- **Steps 1-4:** 2-3 hours (Models, Protocol, Service, JSON)
- **Steps 5-6:** 2-3 hours (UI Implementation)
- **Steps 7-9:** 1-2 hours (Integration)
- **Steps 10-12:** 2-3 hours (Localization, Testing)
- **Total:** 7-11 hours

---

## Configuration Management

### Version Release Checklist

When releasing a new version with significant features:

1. [ ] Update `WhatsNew.json` with new version entry
2. [ ] Set `hasSignificantFeatures: true` for feature releases
3. [ ] Add localized feature descriptions
4. [ ] Test what's new popup in development
5. [ ] Validate JSON structure
6. [ ] Update version number in Info.plist
7. [ ] Test version comparison logic

### Content Guidelines

- Keep feature descriptions concise and child-friendly
- Use appropriate SF Symbols for icons
- Highlight 2-3 most important features maximum
- Avoid technical jargon
- Focus on user benefits rather than technical details

---

## Dependencies

### Existing Code Dependencies

- `UserDefaultsManager` (or `StorageManagerProtocol`)
- `ServiceFactory`
- `AppViewModel`
- Existing localization system
- SwiftUI navigation patterns

### External Dependencies

- None required (pure SwiftUI + Foundation)

---

## Notes for Implementation

1. **Start Simple:** Begin with hardcoded content, then add JSON configuration
2. **Follow Patterns:** Use existing service and MVVM patterns consistently
3. **Test Early:** Manual testing after each major component
4. **Child-Friendly:** Maintain existing design language and accessibility
5. **Localization:** Consider multi-language support from the beginning
6. **Performance:** Ensure minimal impact on app launch time

This implementation guide provides a comprehensive roadmap for adding the What's New feature while maintaining code quality and following established patterns in the SoftDreams app.
