import Foundation

// MARK: - Mock Story Generation Service
/// Mock implementation of StoryGenerationServiceProtocol for development and testing
class MockStoryGenerationService: StoryGenerationServiceProtocol {
  
  // MARK: - Properties
  private let mockDelay: TimeInterval
  private var generationCount = 0
  
  // MARK: - Initialization
  init(mockDelay: TimeInterval = 2.0) {
    self.mockDelay = mockDelay
  }
  
  // MARK: - StoryGenerationServiceProtocol Implementation
  
  func generateStory(for profile: UserProfile, with options: StoryOptions) async throws -> Story {
    Logger.info("Mock: Starting story generation for \(profile.displayName)", category: .storyGeneration)
    
    // Validate inputs
    guard canGenerateStory(for: profile, with: options) else {
      throw StoryGenerationError.invalidProfile
    }
    
    // Simulate generation time
    try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
    
    generationCount += 1
    
    let story = createMockStory(for: profile, with: options)
    
    Logger.info("Mock: Story generation completed - '\(story.title)'", category: .storyGeneration)
    return story
  }
  
  func generateDailyStory(for profile: UserProfile) async throws -> Story {
    let defaultOptions = StoryOptions(
      length: .medium,
      theme: getDailyTheme(),
      characters: []
    )
    
    return try await generateStory(for: profile, with: defaultOptions)
  }
  
  func canGenerateStory(for profile: UserProfile, with options: StoryOptions) -> Bool {
    // Basic validation
    guard !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return false
    }
    
    guard !options.theme.isEmpty else {
      return false
    }
    
    return true
  }
  
  func getSuggestedThemes(for profile: UserProfile) -> [String] {
    let baseThemes = ["Adventure", "Friendship", "Magic", "Animals", "Learning"]
    
    // Customize based on profile
    var themes = baseThemes
    
    if profile.interests.contains("Animals") {
      themes.append("Safari Adventure")
      themes.append("Pet Friends")
    }
    
    if profile.interests.contains("Music") {
      themes.append("Musical Journey")
    }
    
    if profile.interests.contains("Colors") {
      themes.append("Rainbow Magic")
    }
    
    return themes
  }
  
  func getEstimatedGenerationTime(for options: StoryOptions) -> TimeInterval {
    switch options.length {
    case .short:
      return 1.5
    case .medium:
      return 2.0
    case .long:
      return 3.0
    }
  }
  
  // MARK: - Private Helper Methods
  
  private func createMockStory(for profile: UserProfile, with options: StoryOptions) -> Story {
    let title = generateMockTitle(for: profile, with: options)
    let content = generateMockContent(for: profile, with: options)
    
    return Story(
      id: UUID(),
      title: title,
      content: content,
      date: Date(),
      isFavorite: false,
      theme: options.theme,
      length: options.length,
      characters: options.characters,
      ageRange: profile.babyStage,
      readingTime: estimateReadingTime(for: content),
      tags: generateTags(for: profile, with: options)
    )
  }
  
  private func generateMockTitle(for profile: UserProfile, with options: StoryOptions) -> String {
    let themeBasedTitles: [String: [String]] = [
      "Adventure": [
        "\(profile.displayName)'s Great Adventure",
        "The Amazing Journey of \(profile.displayName)",
        "\(profile.displayName) and the Secret Path"
      ],
      "Friendship": [
        "\(profile.displayName) and the Magic of Friendship",
        "How \(profile.displayName) Made New Friends",
        "\(profile.displayName)'s Kindness Adventure"
      ],
      "Magic": [
        "\(profile.displayName) and the Magic Garden",
        "The Magical Day of \(profile.displayName)",
        "\(profile.displayName)'s Enchanted Dream"
      ],
      "Animals": [
        "\(profile.displayName) and the Forest Friends",
        "The Animal Adventure of \(profile.displayName)",
        "\(profile.displayName)'s Safari Dream"
      ],
      "Learning": [
        "\(profile.displayName)'s Learning Journey",
        "How \(profile.displayName) Discovered Something New",
        "\(profile.displayName) and the Curious Question"
      ]
    ]
    
    let theme = options.theme
    let titles = themeBasedTitles[theme] ?? ["\(profile.displayName)'s Special Story"]
    
    return titles.randomElement() ?? "\(profile.displayName)'s Wonderful Adventure"
  }
  
  private func generateMockContent(for profile: UserProfile, with options: StoryOptions) -> String {
    let opening = generateOpening(for: profile, with: options)
    let middle = generateMiddle(for: profile, with: options)
    let ending = generateEnding(for: profile, with: options)
    
    var content = opening
    
    switch options.length {
    case .short:
      content += "\n\n" + middle.prefix(1).joined(separator: "\n\n")
    case .medium:
      content += "\n\n" + middle.joined(separator: "\n\n")
    case .long:
      content += "\n\n" + middle.joined(separator: "\n\n")
      content += "\n\n" + generateExtraAdventure(for: profile)
    }
    
    content += "\n\n" + ending
    
    return content
  }
  
  private func generateOpening(for profile: UserProfile, with options: StoryOptions) -> String {
    let openings = [
      "Once upon a time, \(profile.displayName) woke up to the most beautiful morning.",
      "In a magical place not far from here, \(profile.displayName) was about to discover something wonderful.",
      "One sunny day, \(profile.displayName) looked out the window and saw something amazing.",
      "It was a special day for \(profile.displayName), filled with endless possibilities."
    ]
    
    return openings.randomElement() ?? "Once upon a time, \(profile.displayName) was ready for an adventure."
  }
  
  private func generateMiddle(for profile: UserProfile, with options: StoryOptions) -> [String] {
    var paragraphs: [String] = []
    
    // Theme-based content
    let themeContent = generateThemeContent(for: profile, with: options)
    paragraphs.append(themeContent)
    
    // Character interactions
    if !options.characters.isEmpty {
      let characterContent = generateCharacterContent(for: profile, with: options)
      paragraphs.append(characterContent)
    }
    
    // Interest-based content
    if !profile.interests.isEmpty {
      let interestContent = generateInterestContent(for: profile)
      paragraphs.append(interestContent)
    }
    
    // Age-appropriate challenge
    let challengeContent = generateChallengeContent(for: profile)
    paragraphs.append(challengeContent)
    
    return paragraphs
  }
  
  private func generateThemeContent(for profile: UserProfile, with options: StoryOptions) -> String {
    switch options.theme.lowercased() {
    case "adventure":
      return "\(profile.displayName) discovered a hidden path that led to the most amazing place filled with wonder and excitement."
    case "friendship":
      return "Along the way, \(profile.displayName) met a new friend who was kind and helpful. Together, they shared stories and played wonderful games."
    case "magic":
      return "Suddenly, everything around \(profile.displayName) began to shimmer and glow. The trees whispered gentle secrets, and the flowers danced in the breeze."
    case "animals":
      return "\(profile.displayName) entered a wonderful forest where friendly animals lived together in harmony. Each creature had a special gift to share."
    case "learning":
      return "\(profile.displayName) discovered something amazing that sparked their curiosity. With each question they asked, new doors of understanding opened up."
    default:
      return "\(profile.displayName) found themselves in a wonderful place where anything was possible, and every moment was filled with joy and discovery."
    }
  }
  
  private func generateCharacterContent(for profile: UserProfile, with options: StoryOptions) -> String {
    let character = options.characters.first ?? "a friendly helper"
    return "\(profile.displayName) met \(character), who had the biggest smile and the kindest heart. \(character.capitalized) showed \(profile.displayName) amazing things and taught them about being brave and caring."
  }
  
  private func generateInterestContent(for profile: UserProfile) -> String {
    let interest = profile.interests.randomElement() ?? "exploring"
    return "\(profile.displayName) had an amazing experience with \(interest.lowercased()) that filled their heart with happiness and wonder."
  }
  
  private func generateChallengeContent(for profile: UserProfile) -> String {
    switch profile.babyStage {
    case .pregnancy:
      return "The baby could feel all the love and warmth from the story, growing stronger and more excited to meet their family every day."
    case .newborn, .infant:
      return "\(profile.displayName) felt so safe and loved, surrounded by gentle sounds and soft, warm light that made everything peaceful and beautiful."
    case .toddler:
      return "\(profile.displayName) learned something new and exciting, discovering that being curious and kind always leads to wonderful adventures."
    case .preschooler:
      return "\(profile.displayName) solved a gentle puzzle by being thoughtful and caring, showing that kindness and creativity can overcome any challenge."
    }
  }
  
  private func generateExtraAdventure(for profile: UserProfile) -> String {
    return "But the adventure wasn't over yet! \(profile.displayName) discovered even more magic waiting around the corner. With each new discovery, \(profile.displayName) felt more confident and happy."
  }
  
  private func generateEnding(for profile: UserProfile, with options: StoryOptions) -> String {
    let endings = [
      "And so \(profile.displayName) went to sleep that night with the biggest smile, excited for tomorrow's new adventures.",
      "\(profile.displayName) felt so happy and loved, knowing that every day is full of wonderful surprises and fun discoveries.",
      "As \(profile.displayName) snuggled into bed, they dreamed of all the amazing friends and adventures waiting for them."
    ]
    
    return endings.randomElement() ?? "And they all lived happily ever after."
  }
  
  private func estimateReadingTime(for content: String) -> TimeInterval {
    let wordCount = content.components(separatedBy: .whitespacesAndNewlines).count
    let wordsPerMinute = 150.0
    return TimeInterval(Double(wordCount) / wordsPerMinute * 60)
  }
  
  private func generateTags(for profile: UserProfile, with options: StoryOptions) -> [String] {
    var tags = [options.theme, profile.babyStage.rawValue]
    
    // Add interest-based tags
    tags.append(contentsOf: profile.interests.prefix(2))
    
    // Add character tags
    tags.append(contentsOf: options.characters.prefix(2))
    
    return tags
  }
  
  private func getDailyTheme() -> String {
    let themes = ["Adventure", "Friendship", "Magic", "Animals", "Learning", "Nature", "Kindness"]
    return themes.randomElement() ?? "Adventure"
  }
}
