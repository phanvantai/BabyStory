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
    @State private var refreshID = UUID() // For forcing refresh when theme changes
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
                .id(refreshID) // Force refresh when theme changes
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ThemeChanged"))) { _ in
                    // Force a refresh of the entire app when the theme changes
                    refreshID = UUID()
                }
        }
    }
}
