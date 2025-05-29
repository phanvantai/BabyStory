import SwiftUI

// MARK: - Accessibility Extensions
extension View {
    /// Adds comprehensive accessibility support for buttons
//    func accessibleButton(
//        label: String,
//        hint: String? = nil,
//        traits: AccessibilityTraits = []
//    ) -> some View {
//        self
//            .accessibilityLabel(label)
//            .accessibilityHint(hint ?? "")
//            .accessibilityAddTraits([.isButton] + traits)
//    }
    
    /// Adds accessibility support for cards and interactive elements
    func accessibleCard(
        label: String,
        value: String? = nil,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityValue(value ?? "")
            .accessibilityHint(hint ?? "")
    }
    
    /// Adds accessibility support for headings
    func accessibleHeading(level: Int = 1) -> some View {
        self
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(.h1) // SwiftUI maps this appropriately
    }
    
    /// Adds accessibility support for text input fields
    func accessibleTextField(
        label: String,
        hint: String? = nil,
        isRequired: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label + (isRequired ? " (required)" : ""))
            .accessibilityHint(hint ?? "")
    }
}

// MARK: - Accessibility Constants
struct AccessibilityIdentifiers {
    static let welcomeTitle = "welcome_title"
    static let profileForm = "profile_form"
    static let storyTitle = "story_title"
    static let storyContent = "story_content"
    static let generateStoryButton = "generate_story_button"
    static let saveStoryButton = "save_story_button"
    static let libraryGrid = "library_grid"
    static let settingsButton = "settings_button"
}
