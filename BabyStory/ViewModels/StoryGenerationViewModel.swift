import Foundation

class StoryGenerationViewModel: ObservableObject {
  @Published var options = StoryOptions(length: .medium, theme: "Adventure", characters: [])
  @Published var isLoading = false
  @Published var isGenerating = false
  @Published var generatedStory: Story?
  @Published var error: AppError?
  
  func generateStory(profile: UserProfile, options: StoryOptions?) async {
    await MainActor.run {
      self.isLoading = true
      self.isGenerating = true
      self.error = nil
    }
    
    do {
      // Simulate realistic story generation time
      try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
      
      let storyOptions = options ?? self.options
      let story = try createPersonalizedStory(for: profile, with: storyOptions)
      
      await MainActor.run {
        self.generatedStory = story
        self.isLoading = false
        self.isGenerating = false
      }
    } catch {
      await MainActor.run {
        self.error = .storyGenerationFailed
        self.isLoading = false
        self.isGenerating = false
      }
    }
  }
  
  private func createPersonalizedStory(for profile: UserProfile, with options: StoryOptions) throws -> Story {
    // Validate profile before story generation
    guard !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw AppError.invalidProfile
    }
    
    let storyBuilder = StoryBuilder(profile: profile, options: options)
    return try storyBuilder.generateStory()
  }
}

// MARK: - Story Builder
class StoryBuilder {
  private let profile: UserProfile
  private let options: StoryOptions
  
  init(profile: UserProfile, options: StoryOptions) {
    self.profile = profile
    self.options = options
  }
  
  func generateStory() throws -> Story {
    // Validate that we have minimum required data
    guard !profile.name.isEmpty,
          !profile.interests.isEmpty else {
      throw AppError.invalidProfile
    }
    
    let title = generateTitle()
    let content = generateContent()
    
    return Story(
      id: UUID(),
      title: title,
      content: content,
      date: Date(),
      isFavorite: false
    )
  }
  
  private func generateTitle() -> String {
    let themes = getThemeBasedTitles()
    let characterBased = getCharacterBasedTitles()
    let ageBased = getAgeAppropriateTitles()
    
    let allTitles = themes + characterBased + ageBased
    return allTitles.randomElement() ?? "A Magical Adventure"
  }
  
  private func generateContent() -> String {
    let opening = generateOpening()
    let middle = generateMiddle()
    let ending = generateEnding()
    
    var story = opening
    
    switch options.length {
    case .short:
      story += "\n\n" + middle.prefix(1).joined(separator: "\n\n")
    case .medium:
      story += "\n\n" + middle.joined(separator: "\n\n")
    case .long:
      story += "\n\n" + middle.joined(separator: "\n\n")
      story += "\n\n" + generateExtraAdventure()
    }
    
    story += "\n\n" + ending
    
    return story
  }
  
  private func generateOpening() -> String {
    let timeBasedOpenings = getTimeBasedOpenings()
    let stageBasedOpenings = getStageBasedOpenings()
    
    let allOpenings = timeBasedOpenings + stageBasedOpenings
    var opening = allOpenings.randomElement() ?? "Once upon a time, \(profile.displayName) was ready for an adventure."
    
    // Add interest-based elements to opening
    if !profile.interests.isEmpty {
      let interest = profile.interests.randomElement()!
      opening += " " + getInterestBasedAddition(interest)
    }
    
    return opening
  }
  
  private func generateMiddle() -> [String] {
    var paragraphs: [String] = []
    
    // Theme-based adventure
    paragraphs.append(getThemeBasedAdventure())
    
    // Character interactions
    if !options.characters.isEmpty {
      paragraphs.append(getCharacterInteraction())
    }
    
    // Interest-based scenarios
    if !profile.interests.isEmpty {
      paragraphs.append(getInterestBasedScenario())
    }
    
    // Age-appropriate challenge
    paragraphs.append(getAgeAppropriateChallenge())
    
    return paragraphs.shuffled()
  }
  
  private func generateEnding() -> String {
    let endings = getStageBasedEndings()
    var ending = endings.randomElement() ?? "And so \(profile.displayName) went to sleep with a heart full of joy and dreams full of magic."
    
    // Add personalized touch
    if profile.babyStage == .pregnancy {
      ending = "And the baby in mommy's tummy felt all the love from this wonderful story, already dreaming of the adventures to come."
    }
    
    return ending
  }
  
  // MARK: - Content Generators
  
  private func getThemeBasedTitles() -> [String] {
    let theme = options.effectiveTheme.lowercased()
    
    switch theme {
    case let t where t.contains("adventure"):
      return [
        "\(profile.displayName)'s Great Adventure",
        "The Amazing Journey of \(profile.displayName)",
        "\(profile.displayName) and the Secret Path"
      ]
    case let t where t.contains("friendship"):
      return [
        "\(profile.displayName) and the Magic of Friendship",
        "How \(profile.displayName) Made New Friends",
        "\(profile.displayName)'s Kindness Adventure"
      ]
    case let t where t.contains("magic"):
      return [
        "\(profile.displayName) and the Magic Garden",
        "The Magical Day of \(profile.displayName)",
        "\(profile.displayName)'s Enchanted Dream"
      ]
    case let t where t.contains("animals"):
      return [
        "\(profile.displayName) and the Forest Friends",
        "The Animal Adventure of \(profile.displayName)",
        "\(profile.displayName)'s Safari Dream"
      ]
    case let t where t.contains("learning"):
      return [
        "\(profile.displayName)'s Learning Journey",
        "How \(profile.displayName) Discovered Something New",
        "\(profile.displayName) and the Curious Question"
      ]
    case let t where t.contains("kindness"):
      return [
        "\(profile.displayName)'s Acts of Kindness",
        "How \(profile.displayName) Helped Others",
        "\(profile.displayName) and the Heart of Gold"
      ]
    case let t where t.contains("nature"):
      return [
        "\(profile.displayName) and the Secret Garden",
        "The Nature Walk of \(profile.displayName)",
        "\(profile.displayName)'s Outdoor Adventure"
      ]
    case let t where t.contains("family"):
      return [
        "\(profile.displayName) and the Family Love",
        "A Special Day with \(profile.displayName)'s Family",
        "\(profile.displayName)'s Home Sweet Home"
      ]
    case let t where t.contains("dreams"):
      return [
        "\(profile.displayName)'s Dream Adventure",
        "The Sleepy Journey of \(profile.displayName)",
        "\(profile.displayName) and the Dream Cloud"
      ]
    case let t where t.contains("creativity"):
      return [
        "\(profile.displayName)'s Creative Day",
        "The Artistic Adventure of \(profile.displayName)",
        "\(profile.displayName) and the Magic Paintbrush"
      ]
    default:
      return [
        "\(profile.displayName)'s Special Story",
        "A Day with \(profile.displayName)",
        "\(profile.displayName)'s Wonderful Adventure"
      ]
    }
  }
  
  private func getCharacterBasedTitles() -> [String] {
    guard !options.characters.isEmpty else { return [] }
    
    let character = options.characters.first!
    return [
      "\(profile.displayName) and \(character)",
      "The Adventures of \(profile.displayName) and \(character)",
      "\(profile.displayName) Meets \(character)"
    ]
  }
  
  private func getAgeAppropriateTitles() -> [String] {
    switch profile.babyStage {
    case .pregnancy:
      return [
        "A Story for Baby \(profile.name)",
        "Love Letters to Baby \(profile.name)",
        "Waiting for \(profile.name)"
      ]
    case .newborn, .infant:
      return [
        "Little \(profile.name)'s Gentle Dream",
        "Soft Whispers for \(profile.name)",
        "\(profile.name)'s Peaceful Journey"
      ]
    case .toddler:
      return [
        "\(profile.name)'s Big Discovery",
        "Little \(profile.name) Explores",
        "\(profile.name)'s Fun Day"
      ]
    case .preschooler:
      return [
        "\(profile.name)'s Learning Adventure",
        "Brave \(profile.name)'s Quest",
        "\(profile.name) and the Problem Solvers"
      ]
    }
  }
  
  private func getTimeBasedOpenings() -> [String] {
    let hour = Calendar.current.component(.hour, from: Date())
    
    switch hour {
    case 6...11:
      return [
        "As the morning sun painted the sky with golden colors, \(profile.displayName) woke up ready for a wonderful day.",
        "The birds were singing their morning songs when \(profile.displayName) discovered something amazing.",
        "On this beautiful morning, \(profile.displayName) found a special surprise waiting."
      ]
    case 12...17:
      return [
        "After a fun afternoon of playing, \(profile.displayName) found something magical in the garden.",
        "The afternoon sun was shining brightly when \(profile.displayName) decided to go on an adventure.",
        "During a peaceful afternoon, \(profile.displayName) made an incredible discovery."
      ]
    case 18...21:
      return [
        "As the stars began to twinkle in the evening sky, \(profile.displayName) was getting ready for bed when something wonderful happened.",
        "Just before bedtime, \(profile.displayName) looked out the window and saw something magical.",
        "The moon was rising softly when \(profile.displayName) discovered a special nighttime secret."
      ]
    default:
      return [
        "In the quiet of the night, \(profile.displayName) had the most beautiful dream.",
        "While the world was sleeping peacefully, \(profile.displayName) went on a magical journey in dreamland.",
        "Under the gentle moonlight, \(profile.displayName) found comfort in a wonderful story."
      ]
    }
  }
  
  private func getStageBasedOpenings() -> [String] {
    switch profile.babyStage {
    case .pregnancy:
      let parentNames = profile.parentNames.isEmpty ? ["Mommy", "Daddy"] : profile.parentNames
      let parents = parentNames.joined(separator: " and ")
      return [
        "\(parents) were so excited to meet baby \(profile.name), and they had the most wonderful stories to share.",
        "Every day, \(parents) would talk to baby \(profile.name) and tell amazing tales of love and adventure.",
        "Baby \(profile.name) was growing strong and healthy, listening to all the beautiful stories from \(parents)."
      ]
    case .newborn, .infant:
      return [
        "Little \(profile.displayName) was the most precious baby, loved by everyone around.",
        "Baby \(profile.displayName) had the sweetest dreams filled with gentle sounds and soft colors.",
        "In a cozy, warm room, baby \(profile.displayName) was surrounded by so much love."
      ]
    case .toddler:
      return [
        "\(profile.displayName) was a curious little one who loved to explore and discover new things.",
        "Every day was an adventure for \(profile.displayName), who saw magic in the simplest things.",
        "\(profile.displayName) had such a big imagination and loved to play and learn."
      ]
    case .preschooler:
      return [
        "\(profile.displayName) was growing up to be such a smart and kind child, always ready to help others.",
        "With a heart full of curiosity, \(profile.displayName) loved to ask questions and learn about the world.",
        "\(profile.displayName) was brave and creative, always coming up with the most wonderful ideas."
      ]
    }
  }
  
  private func getInterestBasedAddition(_ interest: String) -> String {
    let additions: [String: [String]] = [
      "Animals": [
        "A friendly little rabbit hopped by and seemed to be inviting \(profile.displayName) to follow.",
        "The birds in the trees were chirping as if they had a secret to share with \(profile.displayName).",
        "A gentle butterfly landed nearby, its colorful wings sparkling in the light."
      ],
      "Music": [
        "Beautiful melodies seemed to float through the air, calling to \(profile.displayName).",
        "The wind chimes on the porch played the most lovely tune.",
        "Somewhere in the distance, a sweet lullaby was playing softly."
      ],
      "Colors": [
        "The world around \(profile.displayName) was painted in the most beautiful colors - purple, pink, and gold.",
        "Rainbow colors danced in the light, creating magic all around \(profile.displayName).",
        "Everything seemed to glow with warm, happy colors."
      ]
    ]
    
    if let matchingAdditions = additions[interest] {
      return matchingAdditions.randomElement() ?? ""
    }
    
    return "Something wonderful was about to happen that had to do with \(interest.lowercased())."
  }
  
  private func getThemeBasedAdventure() -> String {
    let theme = options.effectiveTheme.lowercased()
    
    switch theme {
    case let t where t.contains("adventure"):
      return "\(profile.displayName) discovered a hidden path that led to the most amazing place filled with wonder and excitement. Every step revealed something new and magical."
    case let t where t.contains("friendship"):
      return "Along the way, \(profile.displayName) met a new friend who was kind and helpful. Together, they shared stories and played wonderful games, learning about the joy of friendship."
    case let t where t.contains("magic"):
      return "Suddenly, everything around \(profile.displayName) began to shimmer and glow. The trees whispered gentle secrets, and the flowers danced in the breeze, filling the air with sparkles."
    case let t where t.contains("animals"):
      return "\(profile.displayName) entered a wonderful forest where friendly animals lived together in harmony. Each creature had a special gift to share and a story to tell."
    case let t where t.contains("learning"):
      return "\(profile.displayName) discovered something amazing that sparked their curiosity. With each question they asked, new doors of understanding opened up before them."
    case let t where t.contains("kindness"):
      return "\(profile.displayName) noticed someone who needed help and immediately knew what to do. Their act of kindness created ripples of joy that spread to everyone around."
    case let t where t.contains("nature"):
      return "\(profile.displayName) found a beautiful garden where flowers sang gentle songs and butterflies painted rainbows in the air with their colorful wings."
    case let t where t.contains("family"):
      return "\(profile.displayName) spent the most wonderful time with their family, sharing hugs, laughter, and creating memories that would last forever."
    case let t where t.contains("dreams"):
      return "\(profile.displayName) closed their eyes and found themselves in a dreamy world where clouds were soft like cotton candy and stars twinkled just for them."
    case let t where t.contains("creativity"):
      return "\(profile.displayName) picked up their favorite art supplies and began to create something beautiful. As they worked, their imagination brought their creation to life in the most wonderful way."
    default:
      return "\(profile.displayName) found themselves in a wonderful place where anything was possible, and every moment was filled with joy and discovery."
    }
  }
  
  private func getCharacterInteraction() -> String {
    let character = options.characters.randomElement() ?? "a friendly helper"
    
    return "\(profile.displayName) met \(character), who had the biggest smile and the kindest heart. \(character.capitalized) showed \(profile.displayName) amazing things and taught them about being brave and caring."
  }
  
  private func getInterestBasedScenario() -> String {
    let interest = profile.interests.randomElement()!
    
    let scenarios: [String: [String]] = [
      "Animals": [
        "\(profile.displayName) discovered a magical forest where all the animals could talk and were eager to become friends.",
        "A family of gentle deer invited \(profile.displayName) to join them for a peaceful walk through the meadow."
      ],
      "Music": [
        "\(profile.displayName) found a magical instrument that played the most beautiful melodies, bringing joy to everyone who heard it.",
        "The trees began to sing a gentle song that made \(profile.displayName) feel happy and loved."
      ],
      "Colors": [
        "\(profile.displayName) painted with magical colors that brought their drawings to life, creating a world of wonder.",
        "The sky changed to show all of \(profile.displayName)'s favorite colors, creating the most beautiful rainbow."
      ]
    ]
    
    if let matchingScenarios = scenarios[interest] {
      return matchingScenarios.randomElement() ?? ""
    }
    
    return "\(profile.displayName) had an amazing experience with \(interest.lowercased()) that filled their heart with happiness."
  }
  
  private func getAgeAppropriateChallenge() -> String {
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
  
  private func generateExtraAdventure() -> String {
    return "But the adventure wasn't over yet! \(profile.displayName) discovered even more magic waiting around the corner. With each new discovery, \(profile.displayName) felt more confident and happy, knowing that every day holds the possibility for something wonderful."
  }
  
  private func getStageBasedEndings() -> [String] {
    switch profile.babyStage {
    case .pregnancy:
      let parentNames = profile.parentNames.isEmpty ? ["Mommy and Daddy"] : [profile.parentNames.joined(separator: " and ")]
      return [
        "And baby \(profile.name) felt all this love and warmth, dreaming sweet dreams while growing strong and healthy, surrounded by \(parentNames[0])'s endless love.",
        "The story filled baby \(profile.name) with joy and comfort, and \(parentNames[0]) knew that their little one was already so loved and special.",
        "As the story ended, baby \(profile.name) was peaceful and content, knowing that the most wonderful adventures awaited after birth."
      ]
    case .newborn, .infant:
      return [
        "And so little \(profile.displayName) drifted off to the most peaceful sleep, surrounded by love and gentle dreams.",
        "\(profile.displayName) felt so safe and warm, knowing that tomorrow would bring new gentle discoveries and lots of love.",
        "With a content little sigh, \(profile.displayName) closed their eyes and dreamed of soft colors and gentle sounds."
      ]
    case .toddler:
      return [
        "And \(profile.displayName) went to sleep that night with the biggest smile, excited for tomorrow's new adventures.",
        "\(profile.displayName) felt so happy and loved, knowing that every day is full of wonderful surprises and fun discoveries.",
        "As \(profile.displayName) snuggled into bed, they dreamed of all the amazing friends and adventures waiting for them."
      ]
    case .preschooler:
      return [
        "\(profile.displayName) learned that being kind, brave, and curious makes every day special and filled with magic.",
        "And so \(profile.displayName) went to sleep knowing that they were loved, special, and ready for any adventure that comes their way.",
        "\(profile.displayName) felt proud and happy, understanding that the best adventures come from having a kind heart and an open mind."
      ]
    }
  }
}
