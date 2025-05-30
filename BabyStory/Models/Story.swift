import Foundation

struct Story: Codable, Identifiable, Equatable {
  let id: UUID
  var title: String
  var content: String
  var date: Date
  var isFavorite: Bool
  
  // Enhanced metadata
  var theme: String
  var length: StoryLength
  var characters: [String]
  var ageRange: BabyStage
  var readingTime: TimeInterval? // Estimated reading time in seconds
  var tags: [String] // For categorization and search
  
  // Computed properties
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
  }
  
  var estimatedReadingTimeMinutes: Int {
    guard let readingTime = readingTime else {
      // Fallback estimation: ~150 words per minute
      let wordCount = content.components(separatedBy: .whitespacesAndNewlines).count
      return max(1, wordCount / 150)
    }
    return max(1, Int(readingTime / 60))
  }
  
  var wordCount: Int {
    return content.components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }.count
  }
  
  // Default initializer with enhanced fields
  init(
    id: UUID = UUID(),
    title: String,
    content: String,
    date: Date = Date(),
    isFavorite: Bool = false,
    theme: String,
    length: StoryLength,
    characters: [String] = [],
    ageRange: BabyStage,
    readingTime: TimeInterval? = nil,
    tags: [String] = []
  ) {
    self.id = id
    self.title = title
    self.content = content
    self.date = date
    self.isFavorite = isFavorite
    self.theme = theme
    self.length = length
    self.characters = characters
    self.ageRange = ageRange
    self.readingTime = readingTime
    self.tags = tags
  }
}
