//
//  NotificationPermissionSheet.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import SwiftUI

struct NotificationPermissionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var permissionManager: NotificationPermissionManager
    
    let context: PermissionContext
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    
    @State private var isRequestingPermission = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("notification_permission_sheet_stay_connected".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(context.reason)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Benefits
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(context.benefits, id: \.self) { benefit in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text(benefit)
                                .font(.body)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Permission status specific content
                if permissionManager.permissionStatus.isExplicitlyDenied {
                    deniedPermissionView
                } else {
                    requestPermissionView
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("notification_permission_sheet_navigation_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("notification_permission_sheet_skip".localized) {
                        dismiss()
                        onPermissionDenied()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var requestPermissionView: some View {
        VStack(spacing: 16) {
            Text("notification_permission_sheet_description".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: requestPermission) {
                HStack {
                    if isRequestingPermission {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "bell.badge")
                    }
                    
                    Text(isRequestingPermission ? "notification_permission_sheet_requesting".localized : "notification_permission_sheet_enable_notifications".localized)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isRequestingPermission)
            
            Button("notification_permission_sheet_not_now".localized) {
                dismiss()
                onPermissionDenied()
            }
            .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var deniedPermissionView: some View {
        VStack(spacing: 16) {
            Text("notification_permission_sheet_denied_description".localized)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: openSettings) {
                HStack {
                    Image(systemName: "gear")
                    Text("notification_permission_sheet_open_settings".localized)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button("notification_permission_sheet_continue_without".localized) {
                dismiss()
                onPermissionDenied()
            }
            .foregroundColor(.secondary)
        }
    }
    
    private func requestPermission() {
        isRequestingPermission = true
        
        Task {
            let status = await permissionManager.requestPermission()
            
            await MainActor.run {
                isRequestingPermission = false
                
                if status.canSendNotifications {
                    dismiss()
                    onPermissionGranted()
                } else {
                    // Stay on sheet to show denied state
                    // The permission manager will update its status
                }
            }
        }
    }
    
    private func openSettings() {
        permissionManager.openNotificationSettings()
        dismiss()
        onPermissionDenied()
    }
}

// MARK: - Preview

struct NotificationPermissionSheet_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionSheet(
            permissionManager: NotificationPermissionManager.shared,
            context: .pregnancyReminders,
            onPermissionGranted: {},
            onPermissionDenied: {}
        )
    }
}
