//
//  GradientText.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

// MARK: - Animated Entrance Container
struct AnimatedEntrance<Content: View>: View {
  let content: Content
  let delay: Double
  @State private var showContent = false
  
  init(delay: Double = 0, @ViewBuilder content: () -> Content) {
    self.content = content()
    self.delay = delay
  }
  
  var body: some View {
    content
      .opacity(showContent ? 1 : 0)
      .offset(y: showContent ? 0 : 20)
      .animation(.easeOut(duration: 0.6).delay(delay), value: showContent)
      .onAppear {
        showContent = true
      }
  }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        AnimatedEntrance(delay: 0) {
            Text("Welcome to SoftDreams!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        
        AnimatedEntrance(delay: 0.3) {
            Text("Your magical bedtime stories await")
                .font(.body)
                .foregroundColor(.secondary)
        }
        
        AnimatedEntrance(delay: 0.6) {
            Button("Get Started") {
                // Preview action
            }
            .buttonStyle(.borderedProminent)
        }
        
        AnimatedEntrance(delay: 0.9) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.blue)
                Text("Sweet dreams ahead")
                    .font(.caption)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
}
