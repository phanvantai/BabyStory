//
//  FeedbackCard.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 13/6/25.
//

import SwiftUI

/// A compact card component for collecting user feedback, designed to be placed in the home screen
struct FeedbackCard: View {
    @State private var showFeedbackForm = false
    
    var body: some View {
        Button(action: {
            showFeedbackForm = true
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("feedback_card_title".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("feedback_card_subtitle".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding(16)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
        }
        .appCardStyle()
        .sheet(isPresented: $showFeedbackForm) {
            FeedbackFormView()
        }
    }
}

// MARK: - Previews
#Preview {
    VStack {
        FeedbackCard()
            .padding()
        Spacer()
    }
    .background(Color(UIColor.systemBackground))
}
