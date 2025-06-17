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
    NavigationStack {
      ZStack {
        // Background
        AppGradientBackground()
        
        // Floating decorative elements
        FloatingStars(count: 12)
        
        ScrollView {
          VStack(spacing: 24) {
            // Main settings section
            VStack(spacing: 16) {
              // Section header
              HStack {
                Text("auto_update_settings_title".localized)
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundColor(.primary)
                Spacer()
              }
              .padding(.horizontal, 20)
              
              VStack(spacing: 12) {
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
              }
              .padding(20)
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .fill(.ultraThinMaterial)
                  .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
              )
              .padding(.horizontal, 20)
              
              // Footer text
              if viewModel.autoUpdateEnabled {
                Text("auto_update_enabled_footer".localized)
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding(.horizontal, 20)
              } else {
                Text("auto_update_disabled_footer".localized)
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding(.horizontal, 20)
              }
            }
            
            // Status section
            VStack(spacing: 16) {
              // Section header
              HStack {
                Text("auto_update_status_title".localized)
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundColor(.primary)
                Spacer()
              }
              .padding(.horizontal, 20)
              
              VStack(spacing: 12) {
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
                .padding(.vertical, 4)
                
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
              }
              .padding(20)
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .fill(.ultraThinMaterial)
                  .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
              )
              .padding(.horizontal, 20)
            }
          }
          .padding(.vertical, 20)
        }
      }
      .navigationTitle("auto_update_settings_title".localized)
      .navigationBarTitleDisplayMode(.inline)
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