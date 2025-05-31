//
//  NotificationPermissionPrompt.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import SwiftUI

struct NotificationPermissionPrompt: View {
    @ObservedObject var permissionManager: NotificationPermissionManager
    
    let context: PermissionContext
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    
    @State private var showSheet = false
    
    var body: some View {
        if permissionManager.shouldShowPermissionExplanation(for: context) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("notification_permission_enable_title".localized)
                            .font(.headline)
                        
                        Text(context.reason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Button("notification_permission_learn_more".localized) {
                        showSheet = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("notification_permission_enable_button".localized) {
                        showSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .sheet(isPresented: $showSheet) {
                NotificationPermissionSheet(
                    permissionManager: permissionManager,
                    context: context,
                    onPermissionGranted: onPermissionGranted,
                    onPermissionDenied: onPermissionDenied
                )
            }
        }
    }
}

// MARK: - Convenience View Modifiers

extension View {
    /// Shows a notification permission prompt when appropriate
    func notificationPermissionPrompt(
        permissionManager: NotificationPermissionManager = .shared,
        context: PermissionContext = .general,
        onGranted: @escaping () -> Void = {},
        onDenied: @escaping () -> Void = {}
    ) -> some View {
        VStack(spacing: 16) {
            NotificationPermissionPrompt(
                permissionManager: permissionManager,
                context: context,
                onPermissionGranted: onGranted,
                onPermissionDenied: onDenied
            )
            
            self
        }
    }
}

// MARK: - Preview

struct NotificationPermissionPrompt_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NotificationPermissionPrompt(
                permissionManager: NotificationPermissionManager.shared,
                context: .pregnancyReminders,
                onPermissionGranted: {},
                onPermissionDenied: {}
            )
            
            Spacer()
        }
        .padding()
    }
}
