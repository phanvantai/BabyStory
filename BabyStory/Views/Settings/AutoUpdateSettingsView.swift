//
//  AutoUpdateSettingsView.swift
//  BabyStory
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
              Text("Auto-Update Profile")
                .font(.headline)
              Text("Automatically update baby stage and interests as your child grows")
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
                Text("Baby Stage Progression")
                  .font(.subheadline)
                Text("Update stage based on age (newborn → infant → toddler → preschooler)")
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
                Text("Age-Appropriate Interests")
                  .font(.subheadline)
                Text("Update interests to match your child's developmental stage")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              Toggle("", isOn: $viewModel.interestUpdatesEnabled)
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text("Auto-Update Settings")
        } footer: {
          if viewModel.autoUpdateEnabled {
            Text("Auto-updates help keep your child's profile current as they grow, ensuring stories and activities remain age-appropriate.")
          } else {
            Text("Enable auto-updates to automatically maintain your child's profile as they grow.")
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
              Text("Check for Updates Now")
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
              Text("Last Auto-Update")
                .font(.subheadline)
                .fontWeight(.medium)
              
              Text(lastUpdateInfo)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text("Update Status")
        }
      }
      .navigationBarHidden(true)
      .alert("Update Check Complete", isPresented: $viewModel.showUpdateResult) {
        Button("OK") {
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
        return "Profile last updated: \(formatter.string(from: profile.lastUpdate))"
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
        updateResultMessage = "Profile updated successfully! \(result.updateCount) change(s) were made."
      } else {
        updateResultMessage = "Your profile is already up to date."
      }
    } else {
      updateResultMessage = "Update check failed. Please try again later."
    }
    
    isCheckingForUpdates = false
    showUpdateResult = true
  }
}

#Preview {
  AutoUpdateSettingsView(viewModel: AutoUpdateSettingsViewModel())
}
