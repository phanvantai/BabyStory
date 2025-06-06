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
  
  @Environment(\.locale) private var locale
  
  private var isYearly: Bool {
    product.id.contains("yearly")
  }
  
  private var localization: SubscriptionLocalization {
    SubscriptionLocalization.localization(for: locale)
  }
  
  private var savingsText: String {
    if isYearly {
      return "save_33".localized
    }
    return ""
  }
  
  private var displayPrice: String {
    if isYearly {
      return localization.formatPrice(localization.yearlyPrice)
    } else {
      return localization.formatPrice(localization.monthlyPrice)
    }
  }
  
  private var monthlyEquivalent: String {
    if isYearly {
      return localization.formatMonthlyPrice(localization.yearlyPrice)
    }
    return ""
  }
  
  private var title: String {
    isYearly ? localization.yearlyTitle : localization.monthlyTitle
  }
  
  private var description: String {
    isYearly ? localization.yearlyDescription : localization.monthlyDescription
  }
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 0) {
        // Header
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
              Text(title)
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
            
            Text(description)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          
          Spacer()
          
          VStack(alignment: .trailing, spacing: 2) {
            Text(displayPrice)
              .font(.headline)
//            if isYearly {
//              Text(monthlyEquivalent)
//                .font(.caption)
//                .foregroundStyle(.secondary)
//                .strikethrough()
//            } else {
//              Text(localization.cancelAnytime)
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//            }
          }
        }
        .padding()
        
        // Benefits
        VStack(spacing: 16) {
          // Trial info
          HStack {
            Image(systemName: "gift.fill")
              .foregroundStyle(Color.purple)
            Text(localization.trialPeriod)
              .font(.headline)
            Spacer()
            Text(localization.cancelAnytime)
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
            Text(localization.premiumFeatures)
              .font(.headline)
            
            ForEach(localization.features, id: \.self) { feature in
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
          .fill(Color(.systemBackground))
          .shadow(color: .black.opacity(0.1), radius: 5)
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
