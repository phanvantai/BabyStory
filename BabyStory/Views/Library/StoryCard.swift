//
//  StoryCard.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct StoryCard: View {
  let story: Story
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 12) {
        // Story illustration placeholder
        RoundedRectangle(cornerRadius: 12)
          .fill(LinearGradient(
            colors: [
              Color.blue.opacity(0.3),
              Color.purple.opacity(0.3),
              Color.pink.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ))
          .frame(height: 100)
          .overlay(
            Image(systemName: "book.pages.fill")
              .font(.title)
              .foregroundColor(.white.opacity(0.8))
          )
        
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Text(story.title)
              .font(.headline)
              .fontWeight(.semibold)
              .lineLimit(2)
              .multilineTextAlignment(.leading)
            
            Spacer()
            
            if story.isFavorite {
              Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            }
          }
          
          Text(story.date, style: .date)
            .font(.caption)
            .foregroundColor(.secondary)
          
          Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(16)
      .appCardStyle()
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// MARK: - Previews
#Preview("Story Card - Regular") {
  StoryCard(story: Story.mockStoryCard) {
    print("Card tapped")
  }
  .frame(width: 200)
  .padding()
}

#Preview("Story Card - Favorite") {
  StoryCard(story: Story.mockFavoriteCard) {
    print("Favorite card tapped")
  }
  .frame(width: 200)
  .padding()
}

#Preview("Story Card - Long Title") {
  StoryCard(story: Story.mockLongTitleCard) {
    print("Long title card tapped")
  }
  .frame(width: 200)
  .padding()
}

#Preview("Cards in Grid") {
  LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
    StoryCard(story: Story.mockStoryCard) { }
    StoryCard(story: Story.mockFavoriteCard) { }
    StoryCard(story: Story.mockLongTitleCard) { }
    StoryCard(story: Story.mockRecentCard) { }
  }
  .padding()
  .background(Color(.systemBackground))
}

// MARK: - Mock Data for Previews
extension Story {
  static var mockStoryCard: Story {
    Story(
      id: UUID(),
      title: "The Magical Forest",
      content: "A wonderful adventure awaits in the enchanted woods...",
      date: Date().addingTimeInterval(-86400), // 1 day ago
      isFavorite: false
    )
  }
  
  static var mockFavoriteCard: Story {
    Story(
      id: UUID(),
      title: "Princess Luna's Quest",
      content: "Join Princess Luna on her brave journey to save the kingdom...",
      date: Date().addingTimeInterval(-172800), // 2 days ago
      isFavorite: true
    )
  }
  
  static var mockLongTitleCard: Story {
    Story(
      id: UUID(),
      title: "The Amazing Adventures of Captain Whiskers and the Treasure Island Mystery",
      content: "A thrilling tale of pirates, treasure, and friendship...",
      date: Date().addingTimeInterval(-259200), // 3 days ago
      isFavorite: false
    )
  }
  
  static var mockRecentCard: Story {
    Story(
      id: UUID(),
      title: "The Robot Friend",
      content: "When technology meets friendship, magic happens...",
      date: Date(), // Today
      isFavorite: true
    )
  }
}
