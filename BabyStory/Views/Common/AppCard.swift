//
//  AppCard.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct AppCard<Content: View>: View {
  let content: Content
  let backgroundColor: Color
  let borderColor: Color
  let shadowColor: Color
  
  init(
    backgroundColor: Color = Color.white.opacity(0.9),
    borderColor: Color = Color.gray.opacity(0.2),
    shadowColor: Color = Color.black.opacity(0.1),
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.shadowColor = shadowColor
  }
  
  var body: some View {
    content
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(backgroundColor)
          .stroke(borderColor, lineWidth: 1)
          .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
      )
  }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // Default card
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Default Card")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Text("This is a default AppCard with standard styling")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
            }
            
            // Custom colored card
            AppCard(
                backgroundColor: Color.blue.opacity(0.1),
                borderColor: Color.blue.opacity(0.3),
                shadowColor: Color.blue.opacity(0.2)
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Featured Story")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("NEW")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Text("The magical adventure of Luna and the enchanted forest")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            // Story card example
            AppCard(
                backgroundColor: Color.purple.opacity(0.1),
                borderColor: Color.purple.opacity(0.3),
                shadowColor: Color.purple.opacity(0.2)
            ) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Favorite Story")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("The Dragon's Dream")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                    
                    HStack {
                        Button("Read Again") {
                            // Preview action
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Share") {
                            // Preview action
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            
            // Settings card example
            AppCard(
                backgroundColor: Color.green.opacity(0.1),
                borderColor: Color.green.opacity(0.3),
                shadowColor: Color.green.opacity(0.2)
            ) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Customize your experience")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
