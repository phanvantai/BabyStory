//
//  SettingsNotificationsSectionView.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct SettingsNotificationsSectionView: View {
  @EnvironmentObject var languageManager: LanguageManager
  @ObservedObject var viewModel: SettingsViewModel
  
  var body: some View {
    AnimatedEntrance(delay: 0.6) {
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "bell.fill")
            .foregroundColor(.purple)
            .font(.title3)
          Text("settings_notifications_title".localized)
            .font(.headline)
            .fontWeight(.semibold)
          Spacer()
        }
        
        NotificationStatusView(
          permissionManager: NotificationPermissionManager.shared,
          context: .general,
          onPermissionGranted: {
            Task {
              await viewModel.handleNotificationPermissionGranted()
            }
          },
          onPermissionDenied: {
            viewModel.handleNotificationPermissionDenied()
          }
        )
      }
      .padding(20)
      .appCardStyle()
      .padding(.horizontal, 24)
    }
  }
}

#Preview {
  SettingsNotificationsSectionView(viewModel: SettingsViewModel())
}
