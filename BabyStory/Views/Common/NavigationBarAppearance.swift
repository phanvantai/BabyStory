//
//  NavigationBarAppearance.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI
import UIKit

/// Helper struct to apply global navigation bar appearance settings
struct NavigationBarAppearance {
    
    /// Sets up the global navigation bar appearance for the app
    static func setupGlobalAppearance() {
        // Create a custom appearance for back button
        let appearance = UINavigationBarAppearance()
        
        // Clear background to let our app's background show through
        appearance.configureWithTransparentBackground()
        
        // Customize title text
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        // Apply back button customizations - completely hide the default back button
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear, // Hide default "Back" text
            .font: UIFont.systemFont(ofSize: 0) // Set font size to 0 to hide text
        ]
        appearance.backButtonAppearance = backButtonAppearance
        
        // Remove back button arrow with an empty image
        let emptyImage = UIImage()
        appearance.setBackIndicatorImage(emptyImage, transitionMaskImage: emptyImage)
        
        // Apply the appearance settings to all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Also hide the back button title for pushed view controllers
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(emptyImage, for: .normal, barMetrics: .default)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        UIBarButtonItem.appearance().tintColor = .clear // Make any remaining elements invisible
    }
}

/// View modifier to apply our custom navigation bar appearance
struct CustomNavigationBarAppearanceModifier: ViewModifier {
    init() {
        NavigationBarAppearance.setupGlobalAppearance()
    }
    
    func body(content: Content) -> some View {
        content
    }
}

/// View extension to easily apply custom navigation bar appearance
extension View {
    /// Applies custom navigation bar appearance to the app
    func withCustomNavigationBarAppearance() -> some View {
        self.modifier(CustomNavigationBarAppearanceModifier())
    }
}
