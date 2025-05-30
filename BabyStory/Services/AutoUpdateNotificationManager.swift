//
//  AutoUpdateNotificationManager.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation
import SwiftUI

// MARK: - Auto Update Notification Manager
/// Manages notifications and user communication for auto-profile updates
class AutoUpdateNotificationManager: ObservableObject {
  
  // MARK: - Published Properties
  @Published var showGrowthCelebration: Bool = false
  @Published var showInterestUpdateAlert: Bool = false
  @Published var currentUpdateResult: AutoUpdateResult?
  
  // MARK: - Properties
  private var pendingGrowthMessage: String?
  private var pendingInterestUpdate: InterestUpdate?
  
  // MARK: - Public Methods
  
  /// Processes auto-update results and prepares notifications
  func processUpdateResult(_ result: AutoUpdateResult) {
    guard result.hasUpdates else { return }
    
    currentUpdateResult = result
    
    // Handle stage progression
    if let stageUpdate = result.stageProgression {
      pendingGrowthMessage = stageUpdate.growthMessage
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.showGrowthCelebration = true
      }
    }
    
    // Handle interest updates
    if let interestUpdate = result.interestUpdate {
      pendingInterestUpdate = interestUpdate
      
      // Show interest update alert after growth celebration (if any)
      let delay = result.stageProgression != nil ? 3.0 : 0.5
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        self.showInterestUpdateAlert = true
      }
    }
  }
  
  /// Dismisses all notifications
  func dismissNotifications() {
    showGrowthCelebration = false
    showInterestUpdateAlert = false
    currentUpdateResult = nil
    pendingGrowthMessage = nil
    pendingInterestUpdate = nil
  }
  
  /// Gets the growth message for display
  func getGrowthMessage() -> String {
    return pendingGrowthMessage ?? "Your little one is growing up! 🌟"
  }
  
  /// Gets interest update information for display
  func getInterestUpdateInfo() -> InterestUpdateDisplayInfo? {
    guard let update = pendingInterestUpdate else { return nil }
    
    return InterestUpdateDisplayInfo(
      removedCount: update.removedInterests.count,
      addedCount: update.addedInterests.count,
      removedInterests: update.removedInterests,
      addedInterests: update.addedInterests,
      totalInterests: update.newInterests.count
    )
  }
}

// MARK: - Supporting Models

/// Display information for interest updates
struct InterestUpdateDisplayInfo {
  let removedCount: Int
  let addedCount: Int
  let removedInterests: [String]
  let addedInterests: [String]
  let totalInterests: Int
  
  var hasRemovedInterests: Bool { removedCount > 0 }
  var hasAddedInterests: Bool { addedCount > 0 }
  
  var updateSummary: String {
    switch (hasRemovedInterests, hasAddedInterests) {
    case (true, true):
      return "We've updated \(removedCount + addedCount) interests to match your child's new stage"
    case (false, true):
      return "We've added \(addedCount) new age-appropriate interests"
    case (true, false):
      return "We've removed \(removedCount) interests that are no longer age-appropriate"
    case (false, false):
      return "Your interests are up to date"
    }
  }
}

// MARK: - Growth Celebration View

/// A celebratory view shown when the child reaches a new stage
struct GrowthCelebrationView: View {
  let message: String
  let onDismiss: () -> Void
  
  @State private var showConfetti = false
  @State private var scale: CGFloat = 0.8
  @State private var opacity: Double = 0
  
  var body: some View {
    ZStack {
      // Background overlay
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture {
          onDismiss()
        }
      
      // Celebration card
      VStack(spacing: 20) {
        // Celebration emoji
        Text("🎉")
          .font(.system(size: 60))
          .scaleEffect(showConfetti ? 1.2 : 1.0)
          .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatCount(3), value: showConfetti)
        
        // Growth message
        Text(message)
          .font(.title2)
          .fontWeight(.semibold)
          .multilineTextAlignment(.center)
          .foregroundColor(.primary)
          .padding(.horizontal)
        
        Text("Stories and activities have been updated to match this exciting milestone!")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
        
        // Dismiss button
        Button("Continue") {
          onDismiss()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding(24)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(.regularMaterial)
          .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
      )
      .padding(40)
      .scaleEffect(scale)
      .opacity(opacity)
    }
    .onAppear {
      withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
        scale = 1.0
        opacity = 1.0
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        showConfetti = true
      }
    }
  }
}

// MARK: - Interest Update Alert

/// Alert view for interest updates
struct InterestUpdateAlert: View {
  let updateInfo: InterestUpdateDisplayInfo
  let onDismiss: () -> Void
  
  var body: some View {
    VStack(spacing: 16) {
      // Header
      HStack {
        Image(systemName: "star.circle.fill")
          .foregroundColor(.yellow)
          .font(.title2)
        Text("Interests Updated")
          .font(.headline)
          .fontWeight(.semibold)
      }
      
      // Summary
      Text(updateInfo.updateSummary)
        .font(.body)
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
      
      // Details if available
      if updateInfo.hasAddedInterests {
        VStack(alignment: .leading, spacing: 8) {
          Text("New interests added:")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.green)
          
          ForEach(updateInfo.addedInterests, id: \.self) { interest in
            HStack {
              Image(systemName: "plus.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
              Text(interest)
                .font(.caption)
            }
          }
        }
        .padding(.vertical, 8)
      }
      
      if updateInfo.hasRemovedInterests {
        VStack(alignment: .leading, spacing: 8) {
          Text("Outgrown interests:")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.orange)
          
          ForEach(updateInfo.removedInterests, id: \.self) { interest in
            HStack {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.orange)
                .font(.caption)
              Text(interest)
                .font(.caption)
            }
          }
        }
        .padding(.vertical, 8)
      }
      
      // Action buttons
      HStack(spacing: 12) {
        Button("Got it") {
          onDismiss()
        }
        .buttonStyle(.bordered)
        
        Button("Review Interests") {
          onDismiss()
          // TODO: Navigate to interests editing
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(.regularMaterial)
        .shadow(color: .black.opacity(0.1), radius: 5)
    )
    .padding(20)
  }
}
