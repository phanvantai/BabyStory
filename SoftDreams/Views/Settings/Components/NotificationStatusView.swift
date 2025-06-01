//
//  NotificationStatusView.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct NotificationStatusView: View {
    @ObservedObject var permissionManager: NotificationPermissionManager
    
    let context: PermissionContext
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            switch permissionManager.permissionStatus {
            case .authorized, .provisional:
                notificationEnabledView
            case .denied:
                notificationDeniedView
            case .notDetermined, .unknown:
                notificationPromptView
            }
        }
    }
    
    @ViewBuilder
    private var notificationEnabledView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("settings_notifications_enabled_title".localized)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("settings_notifications_enabled_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("settings_manage".localized) {
                openNotificationSettings()
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var notificationDeniedView: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("settings_notifications_disabled_title".localized)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("settings_notifications_disabled_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("settings_enable".localized) {
                openNotificationSettings()
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var notificationPromptView: some View {
        NotificationPermissionPrompt(
            permissionManager: permissionManager,
            context: context,
            onPermissionGranted: onPermissionGranted,
            onPermissionDenied: onPermissionDenied
        )
    }
    
    private func openNotificationSettings() {
        permissionManager.openNotificationSettings()
    }
}

// MARK: - Preview

struct NotificationStatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            NotificationStatusView(
                permissionManager: NotificationPermissionManager.shared,
                context: .general,
                onPermissionGranted: {},
                onPermissionDenied: {}
            )
            
            Spacer()
        }
        .padding()
    }
}
