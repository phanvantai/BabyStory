//
//  SubscriptionOptionButton.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 4/6/25.
//

import SwiftUI
import StoreKit

struct SubscriptionOptionButton: View {
  let product: Product
  let isSelected: Bool
  let action: () -> Void
  let features: [String] 
  
  @Environment(\.locale) private var locale
  
  private var isYearly: Bool {
    product.id.contains("yearly")
  }
  
  private var savingsText: String {
    if isYearly {
      return "save_33".localized
    }
    return ""
  }
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 0) {
        // Header
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
              Text(product.displayName)
                .font(.headline)
              
              if isYearly {
                Text(savingsText)
                  .font(.caption)
                  .fontWeight(.bold)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(
                    LinearGradient(
                      colors: [Color.orange, Color.pink],
                      startPoint: .leading,
                      endPoint: .trailing
                    )
                  )
                  .foregroundColor(.white)
                  .clipShape(Capsule())
              }
            }
            
            Text(product.description)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          
          Spacer()
          
          VStack(alignment: .trailing, spacing: 2) {
            Text(product.displayPrice)
              .font(.headline)
          }
        }
        .padding()
        
        // Benefits
        VStack(spacing: 16) {
          // Trial info
          HStack {
            Image(systemName: "gift.fill")
              .foregroundStyle(Color.purple)
            Text("subscription_trial_period".localized)
              .font(.headline)
            Spacer()
            Text("subscription_cancel_anytime".localized)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.purple.opacity(0.1))
          )
          
          // Premium features
          VStack(alignment: .leading, spacing: 12) {
            Text("subscription_premium_features".localized)
              .font(.headline)
            
            ForEach(features, id: \.self) { feature in
              FeatureRow(icon: getIconForFeature(feature), text: feature)
            }
          }
          .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
        .frame(maxHeight: isSelected ? .none : 0)
        .opacity(isSelected ? 1 : 0)
      }
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.systemBackground).opacity(0.3))
          .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
      )
    }
    .buttonStyle(PlainButtonStyle())
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
  }
  
  private func getIconForFeature(_ feature: String) -> String {
    // Map feature text to appropriate SF Symbol
    switch feature {
    case _ where feature.contains("stories"):
      return "sparkles"
    case _ where feature.contains("AI") || feature.contains("models"):
      return "brain"
    case _ where feature.contains("voice") || feature.contains("narration"):
      return "waveform"
    case _ where feature.contains("settings"):
      return "slider.horizontal.3"
    case _ where feature.contains("profiles"):
      return "person.2"
    default:
      return "star.fill"
    }
  }
}
