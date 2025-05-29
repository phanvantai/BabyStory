//
//  BabyStoryApp.swift
//  BabyStory
//
//  Created by Tai Phan Van on 28/5/25.
//

import SwiftUI

@main
struct BabyStoryApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
                .withCustomNavigationBarAppearance() // Apply custom navigation bar appearance
                .animation(.easeInOut(duration: 0.3), value: themeManager.preferredColorScheme)
        }
    }
}
