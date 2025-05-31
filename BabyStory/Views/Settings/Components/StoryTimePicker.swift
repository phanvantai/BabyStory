//
//  StoryTimePicker.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import SwiftUI

struct StoryTimePicker: View {
  @Binding var storyTime: Date
  @Binding var showTimePicker: Bool
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "clock.fill")
          .foregroundColor(.orange)
          .font(.title3)
        Text("settings_story_time_title".localized)
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      Button(action: {
        showTimePicker = true
      }) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("settings_preferred_story_time".localized)
              .font(.body)
              .fontWeight(.medium)
              .foregroundColor(.primary)
            
            Text(storyTime.formatted(date: .omitted, time: .shortened))
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(AppTheme.cardBackground.opacity(0.8))
            .stroke(AppTheme.defaultCardBorder, lineWidth: 1)
        )
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    StoryTimePicker(
      storyTime: .constant(Date()),
      showTimePicker: .constant(false)
    )
    .padding()
  }
}
