//
//  SettingsParentalControlsSectionView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 31/5/25.
//

import SwiftUI

struct SettingsParentalControlsSectionView: View {
  @Binding var showParentalLock: Bool
  
  var body: some View {
    AnimatedEntrance(delay: 0.7) {
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "lock.shield.fill")
            .foregroundColor(.orange)
            .font(.title3)
          Text("Parental Controls")
            .font(.headline)
            .fontWeight(.semibold)
          Spacer()
        }
        
        Button(action: { showParentalLock = true }) {
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("Parental Lock")
                .font(.body)
                .fontWeight(.medium)
              Text("Manage access and restrictions")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .padding(.vertical, 12)
          .contentShape(Rectangle())
        }
      }
      .padding(20)
      .appCardStyle()
      .padding(.horizontal, 24)
    }
  }
}

#Preview {
  SettingsParentalControlsSectionView(showParentalLock: .constant(false))
}
