//
//  AppIconPicker.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 12/6/25.
//

import SwiftUI

struct AppIconPicker: View {
  @ObservedObject var viewModel: SettingsViewModel
  @State private var showingAlert = false
  @State private var alertMessage = ""
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Image(systemName: "app.badge")
          .foregroundColor(.orange)
          .font(.title3)
        Text("settings_app_icon_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      VStack(spacing: 12) {
        ForEach(AppIcon.allCases, id: \.self) { icon in
          Button(action: {
            Task {
              await changeIcon(to: icon)
            }
          }) {
            HStack(spacing: 16) {
              // Icon preview with background
              ZStack {
                RoundedRectangle(cornerRadius: 12)
                  .fill(viewModel.appIcon == icon ?
                        LinearGradient(
                          gradient: Gradient(colors: [Color.orange, Color.red]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                        ) :
                          LinearGradient(
                            gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemBackground)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                  )
                  .frame(width: 44, height: 44)
                  .overlay(
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(viewModel.appIcon == icon ? Color.orange : Color(UIColor.separator).opacity(0.3), lineWidth: viewModel.appIcon == icon ? 2 : 1)
                  )
                
                Image(systemName: icon.icon)
                  .font(.title3)
                  .foregroundColor(viewModel.appIcon == icon ? .white : .primary)
              }
              
              // Icon info
              VStack(alignment: .leading, spacing: 4) {
                Text(icon.displayName)
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(.primary)
                
                Text(icon.description)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              // Selection indicator
              if viewModel.appIcon == icon {
                Image(systemName: "checkmark.circle.fill")
                  .font(.title3)
                  .foregroundColor(.orange)
              } else {
                Image(systemName: "circle")
                  .font(.title3)
                  .foregroundColor(.gray.opacity(0.4))
              }
            }
            .padding(16)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.appIcon == icon ? Color.orange.opacity(0.1) : Color(UIColor.systemBackground).opacity(0.5))
                .stroke(viewModel.appIcon == icon ? Color.orange.opacity(0.3) : Color(UIColor.separator).opacity(0.3), lineWidth: 1)
            )
          }
          .buttonStyle(PlainButtonStyle())
          .scaleEffect(viewModel.appIcon == icon ? 1.02 : 1.0)
          .animation(.easeInOut(duration: 0.2), value: viewModel.appIcon)
        }
      }
    }
    .alert("settings_app_icon_change_error".localized, isPresented: $showingAlert) {
      Button("settings_ok".localized) {
        showingAlert = false
      }
    } message: {
      Text(alertMessage)
    }
  }
  
  // MARK: - Private Methods
  private func changeIcon(to icon: AppIcon) async {
    
    let _ = viewModel.setAlternateAppIcon(icon: icon)
    
//    if !success {
//      await MainActor.run {
//        alertMessage = "settings_app_icon_change_failed".localized
//        showingAlert = true
//      }
//    }
  }
}

#Preview {
  VStack {
    AppIconPicker(viewModel: SettingsViewModel())
      .padding()
    
    Spacer()
  }
  .background(Color.gray.opacity(0.1))
}
