//
//  EmptyStateCard.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct EmptyStateCard: View {
  let title: String
  let message: String
  let icon: String
  let iconColor: Color
  let actionTitle: String?
  let action: (() -> Void)?
  
  init(
    title: String,
    message: String,
    icon: String,
    iconColor: Color = .gray,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.message = message
    self.icon = icon
    self.iconColor = iconColor
    self.actionTitle = actionTitle
    self.action = action
  }
  
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: icon)
        .font(.system(size: 50))
        .foregroundColor(iconColor.opacity(0.6))
      
      VStack(spacing: 8) {
        Text(title)
          .font(.title2)
          .fontWeight(.semibold)
        
        Text(message)
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
      
      if let actionTitle = actionTitle, let action = action {
        Button(action: action) {
          Text(actionTitle)
            .font(.headline)
            .fontWeight(.medium)
        }
        .buttonStyle(SecondaryButtonStyle())
      }
    }
    .padding(40)
    .appCardStyle()
  }
}

#Preview {
  EmptyStateCard(title: "Title", message: "Message", icon: "questionmark.circle.fill", actionTitle: "Retry") {
    print("Action tapped")
  }
  
}
