//
//  AutoUpdateSettingsView.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import SwiftUI

struct AutoUpdateSettingsView: View {
  @ObservedObject var viewModel: AutoUpdateSettingsViewModel
  
  var body: some View {
    NavigationView {
      List {
        Section {
          // Auto-update toggle
          HStack {
            Image(systemName: "arrow.clockwise.circle.fill")
              .foregroundColor(.blue)
              .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
              Text("auto_update_profile_title".localized)
                .font(.headline)
              Text("auto_update_profile_description".localized)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $viewModel.autoUpdateEnabled)
          }
          .padding(.vertical, 4)
          
          // Stage progression toggle
          if viewModel.autoUpdateEnabled {
            HStack {
              Image(systemName: "figure.child.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
              
              VStack(alignment: .leading, spacing: 4) {
                Text("auto_update_stage_progression_title".localized)
                  .font(.subheadline)
                Text("auto_update_stage_progression_description".localized)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              Toggle("", isOn: $viewModel.stageProgressionEnabled)
            }
            .padding(.vertical, 4)
            
            // Interest updates toggle
            HStack {
              Image(systemName: "star.circle.fill")
                .foregroundColor(.yellow)
                .font(.title3)
              
              VStack(alignment: .leading, spacing: 4) {
                Text("auto_update_interests_title".localized)
                  .font(.subheadline)
                Text("auto_update_interests_description".localized)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              Toggle("", isOn: $viewModel.interestUpdatesEnabled)
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text("auto_update_settings_title".localized)
        } footer: {
          if viewModel.autoUpdateEnabled {
            Text("auto_update_enabled_footer".localized)
          } else {
            Text("auto_update_disabled_footer".localized)
          }
        }
        
        Section {
          // Manual update check
          Button(action: {
            Task {
              await viewModel.performManualUpdate()
            }
          }) {
            HStack {
              Image(systemName: "arrow.clockwise")
                .foregroundColor(.blue)
              Text("auto_update_check_now".localized)
              Spacer()
              if viewModel.isCheckingForUpdates {
                ProgressView()
                  .scaleEffect(0.8)
              }
            }
          }
          .disabled(viewModel.isCheckingForUpdates)
          
          // Last update info
          if let lastUpdateInfo = viewModel.lastUpdateInfo {
            VStack(alignment: .leading, spacing: 8) {
              Text("auto_update_last_update".localized)
                .font(.subheadline)
                .fontWeight(.medium)
              
              Text(lastUpdateInfo)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text("auto_update_status_title".localized)
        }
      }
      .navigationBarHidden(true)
      .alert("auto_update_check_complete_title".localized, isPresented: $viewModel.showUpdateResult) {
        Button("settings_ok".localized) {
          viewModel.showUpdateResult = false
        }
      } message: {
        Text(viewModel.updateResultMessage)
      }
    }
  }
}

#Preview {
  AutoUpdateSettingsView(viewModel: AutoUpdateSettingsViewModel())
}
