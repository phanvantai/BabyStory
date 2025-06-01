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

// MARK: - Auto Update Settings ViewModel

class AutoUpdateSettingsViewModel: ObservableObject {
  @Published var autoUpdateEnabled: Bool {
    didSet {
      saveSettings()
    }
  }
  
  @Published var stageProgressionEnabled: Bool {
    didSet {
      saveSettings()
    }
  }
  
  @Published var interestUpdatesEnabled: Bool {
    didSet {
      saveSettings()
    }
  }
  
  @Published var isCheckingForUpdates = false
  @Published var showUpdateResult = false
  @Published var updateResultMessage = ""
  
  private let autoUpdateService = AutoProfileUpdateService()
  
  var lastUpdateInfo: String? {
    do {
      if let profile = try StorageManager.shared.loadProfile() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return String(format: "auto_update_last_updated_format".localized, formatter.string(from: profile.lastUpdate))
      }
    } catch {
      Logger.error("Failed to get last update info: \(error.localizedDescription)", category: .settings)
    }
    return nil
  }
  
  init() {
    // Load settings from UserDefaults with sensible defaults
    // Check if this is the first time by looking for a key that indicates settings have been initialized
    let hasInitializedSettings = UserDefaults.standard.object(forKey: "auto_update_settings_initialized") != nil
    
    if !hasInitializedSettings {
      // First time - set user-friendly defaults
      self.autoUpdateEnabled = true
      self.stageProgressionEnabled = true
      self.interestUpdatesEnabled = true
      
      // Mark as initialized and save defaults
      UserDefaults.standard.set(true, forKey: "auto_update_settings_initialized")
      UserDefaults.standard.set(true, forKey: "auto_update_enabled")
      UserDefaults.standard.set(true, forKey: "stage_progression_enabled")
      UserDefaults.standard.set(true, forKey: "interest_updates_enabled")
    } else {
      // Load existing settings
      self.autoUpdateEnabled = UserDefaults.standard.bool(forKey: "auto_update_enabled")
      self.stageProgressionEnabled = UserDefaults.standard.bool(forKey: "stage_progression_enabled")
      self.interestUpdatesEnabled = UserDefaults.standard.bool(forKey: "interest_updates_enabled")
    }
  }
  
  private func saveSettings() {
    UserDefaults.standard.set(autoUpdateEnabled, forKey: "auto_update_enabled")
    UserDefaults.standard.set(stageProgressionEnabled, forKey: "stage_progression_enabled")
    UserDefaults.standard.set(interestUpdatesEnabled, forKey: "interest_updates_enabled")
  }
  
  @MainActor
  func performManualUpdate() async {
    isCheckingForUpdates = true
    updateResultMessage = ""
    
    let result = await autoUpdateService.performAutoUpdate()
    
    if result.isSuccess {
      if result.hasUpdates {
        updateResultMessage = String(format: "auto_update_success_message".localized, result.updateCount)
      } else {
        updateResultMessage = "auto_update_no_updates_message".localized
      }
    } else {
      updateResultMessage = "auto_update_failed_message".localized
    }
    
    isCheckingForUpdates = false
    showUpdateResult = true
  }
}

#Preview {
  AutoUpdateSettingsView(viewModel: AutoUpdateSettingsViewModel())
}
