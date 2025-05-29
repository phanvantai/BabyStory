//
//  CustomBackButton.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

/// A custom back button component that matches the BabyStory app's theme and style
struct CustomBackButton: View {
    var action: () -> Void
    var label: String? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // Execute the action
            action()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 20, height: 20)
                .padding(10)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(colorScheme == .dark ? 0.25 : 0.15),
                                    Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.purple.opacity(0.3),
                                            Color.blue.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: AppTheme.primaryButton),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: AppTheme.defaultCardShadow, radius: 3, x: 0, y: 1)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .contentShape(Circle()) // Makes entire circle tappable
        }
        .buttonStyle(PlainButtonStyle()) // Use plain style to handle animations ourselves
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        // Even though we're not showing the label visually, we maintain it for accessibility
        .accessibilityLabel(label ?? "Back")
        .accessibilityHint("Navigate to previous screen")
    }
}

/// A view modifier that customizes the navigation bar with our custom back button
struct CustomBackButtonModifier: ViewModifier {
    @Environment(\.presentationMode) private var presentationMode
    var label: String? = nil
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: label) // Label is kept for accessibility but not visually displayed
                }
            }
    }
}

/// View extension to easily apply our custom back button
extension View {
    /// Applies a custom back button to the navigation bar
    /// - Parameter label: Optional label text to display next to the back chevron
    /// - Returns: Modified view with custom back button
    func customBackButton(label: String? = nil) -> some View {
        self.modifier(CustomBackButtonModifier(label: label))
    }
}

#Preview("Standalone Back Button") {
    NavigationStack {
        VStack {
            Text("Content View")
                .navigationTitle("Detail")
                .customBackButton(label: "Back") // Label still used for accessibility
            
            // Show standalone button for reference
            CustomBackButton(action: {}, label: "Preview Button")
        }
    }
}
