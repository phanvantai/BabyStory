import Foundation

// MARK: - Anthropic Claude Story Generation Service
/// Anthropic Claude implementation of StoryGenerationServiceProtocol for AI-powered story generation
class AnthropicClaudeStoryGenerationService: StoryGenerationServiceProtocol {
  
  // MARK: - Properties
  private let apiKey: String
  private let baseURL: String
  private let model: String
  private let maxTokens: Int
  private let temperature: Double
  private let session: URLSession
  private let apiVersion = "2023-06-01" // Anthropic API version
  
  // MARK: - Initialization
  init(
    apiKey: String,
    model: String = "claude-3-haiku-20240307",
    maxTokens: Int = 1500,
    temperature: Double = 0.7,
    session: URLSession = .shared,
    baseURL: String? = nil
  ) {
    self.apiKey = apiKey
    self.model = model
    self.maxTokens = maxTokens
    self.temperature = temperature
    self.session = session
    self.baseURL = baseURL ?? AnthropicAPIConfig.baseURL + "/messages"
  }
  
  // MARK: - StoryGenerationServiceProtocol Implementation
  
  func generateStory(for profile: UserProfile, with options: StoryOptions) async throws -> Story {
    Logger.info("Claude: Starting story generation for \(profile.displayName)", category: .storyGeneration)
    
    // Validate inputs
    guard canGenerateStory(for: profile, with: options) else {
      throw StoryGenerationError.invalidProfile
    }
    
    guard !apiKey.isEmpty else {
      Logger.error("Claude: API key is missing", category: .storyGeneration)
      throw StoryGenerationError.serviceUnavailable
    }
    
    do {
      let prompt = buildPrompt(for: profile, with: options)
      let response = try await makeClaudeRequest(prompt: prompt)
      let story = createStory(from: response, for: profile, with: options)
      
      Logger.info("Claude: Story generation completed - '\(story.title)'", category: .storyGeneration)
      return story
      
    } catch let error as StoryGenerationError {
      throw error
    } catch {
      Logger.error("Claude: Story generation failed - \(error.localizedDescription)", category: .storyGeneration)
      throw StoryGenerationError.generationFailed
    }
  }
  
  func generateDailyStory(for profile: UserProfile) async throws -> Story {
    let defaultOptions = StoryOptions(
      length: .medium,
      theme: getDailyTheme(for: profile),
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
    
    guard !apiKey.isEmpty else {
      return false
    }
    
    return true
  }
  
  func getSuggestedThemes(for profile: UserProfile) -> [String] {
    // Start with base themes from StoryTheme enum
    var themes = StoryTheme.allCases.map { $0.rawValue }
    
    // Add custom themes based on profile interests
    if profile.interests.contains("Animals") {
      themes.append(contentsOf: ["Safari Adventure", "Pet Friends", "Ocean Life"])
    }
    
    if profile.interests.contains("Music") {
      themes.append(contentsOf: ["Musical Journey", "Dancing Animals"])
    }
    
    if profile.interests.contains("Colors") {
      themes.append(contentsOf: ["Rainbow Magic", "Colorful Garden"])
    }
    
    if profile.interests.contains("Sports") {
      themes.append(contentsOf: ["Team Adventure", "Playground Fun"])
    }
    
    // Age-appropriate themes
    switch profile.babyStage {
    case .pregnancy:
      themes.append(contentsOf: ["Gentle Dreams", "Peaceful Journey"])
    case .newborn, .infant:
      themes.append(contentsOf: ["Soft Lullaby", "Gentle Touch", "Warm Embrace"])
    case .toddler:
      themes.append(contentsOf: ["First Steps", "Discovery Time", "Curious Explorer"])
    case .preschooler:
      themes.append(contentsOf: ["Big Kid Adventure", "Problem Solving", "Creative Play"])
    }
    
    return Array(Set(themes)).sorted()
  }
  
  func getEstimatedGenerationTime(for options: StoryOptions) -> TimeInterval {
    // Claude API typically takes 2-8 seconds depending on length
    switch options.length {
    case .short:
      return 3.0
    case .medium:
      return 5.0
    case .long:
      return 8.0
    }
  }
  
  // MARK: - Private Helper Methods
  
  private func buildPrompt(for profile: UserProfile, with options: StoryOptions) -> String {
    let ageDescription = getAgeDescription(for: profile)
    let lengthDescription = getLengthDescription(for: options.length)
    let interestsText = profile.interests.isEmpty ? "" : " The child loves \(profile.interests.joined(separator: ", "))."
    let charactersText = options.characters.isEmpty ? "" : " Include these characters: \(options.characters.joined(separator: ", "))."
    let languageInstruction = getLanguageInstruction(for: profile.language)
    
    return """
    Write a personalized children's story with the following requirements:
    
    - Child's name: \(profile.displayName)
    - Age/Stage: \(ageDescription)
    - Theme: \(options.effectiveTheme)
    - Length: \(lengthDescription)
    - Language: \(languageInstruction)
    - Story should be appropriate for \(ageDescription)
    \(interestsText)\(charactersText)
    
    Guidelines:
    - Write the story in \(profile.language.nativeName) language
    - Use simple, age-appropriate language suitable for \(profile.babyStage.displayName)
    - Include positive messages and gentle lessons
    - Make the story engaging and imaginative
    - Ensure the child is the main character
    - Include sensory details (sounds, colors, textures)
    - End with a comforting, happy conclusion
    - Avoid scary or negative content
    - Use cultural context appropriate for \(profile.language.nativeName) speakers when relevant
    
    Format the response as a complete story with a clear beginning, middle, and end.
    """
  }
  
  private func getAgeDescription(for profile: UserProfile) -> String {
    switch profile.babyStage {
    case .pregnancy:
      return "unborn baby (pregnancy stage)"
    case .newborn:
      return "newborn baby (0-3 months)"
    case .infant:
      return "infant (3-12 months)"
    case .toddler:
      return "toddler (13-36 months / 1-3 years)"
    case .preschooler:
      return "preschooler (37-60 months / 3-5 years)"
    }
  }
  
  private func getLengthDescription(for length: StoryLength) -> String {
    return length.aiPromptDescription
  }
  
  private func getLanguageInstruction(for language: Language) -> String {
    switch language.code {
    case "en":
      return "English - Use simple, clear English appropriate for children"
    case "vi":
      return "Vietnamese (Tiếng Việt) - Use simple, clear Vietnamese appropriate for children. Include Vietnamese cultural elements when appropriate"
    case "es":
      return "Spanish (Español) - Use simple, clear Spanish appropriate for children. Include Hispanic cultural elements when appropriate"
    case "fr":
      return "French (Français) - Use simple, clear French appropriate for children. Include French cultural elements when appropriate"
    case "de":
      return "German (Deutsch) - Use simple, clear German appropriate for children. Include German cultural elements when appropriate"
    case "it":
      return "Italian (Italiano) - Use simple, clear Italian appropriate for children. Include Italian cultural elements when appropriate"
    case "pt":
      return "Portuguese (Português) - Use simple, clear Portuguese appropriate for children. Include Portuguese cultural elements when appropriate"
    case "zh":
      return "Chinese (中文) - Use simple, clear Chinese appropriate for children. Include Chinese cultural elements when appropriate"
    case "ja":
      return "Japanese (日本語) - Use simple, clear Japanese appropriate for children. Include Japanese cultural elements when appropriate"
    case "ko":
      return "Korean (한국어) - Use simple, clear Korean appropriate for children. Include Korean cultural elements when appropriate"
    case "ar":
      return "Arabic (العربية) - Use simple, clear Arabic appropriate for children. Include Arabic cultural elements when appropriate"
    default:
      return "English - Use simple, clear English appropriate for children (fallback language)"
    }
  }
  
  private func makeClaudeRequest(prompt: String) async throws -> String {
    guard let url = URL(string: baseURL) else {
      throw StoryGenerationError.serviceUnavailable
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
    request.setValue("anthropic-version=\(apiVersion)", forHTTPHeaderField: "anthropic-version")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody = ClaudeRequest(
      model: model,
      messages: [
        ClaudeMessage(role: "user", content: prompt)
      ],
      maxTokens: maxTokens,
      temperature: temperature
    )
    
    do {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      request.httpBody = try encoder.encode(requestBody)
    } catch {
      Logger.error("Claude: Failed to encode request - \(error)", category: .storyGeneration)
      throw StoryGenerationError.generationFailed
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
          Logger.error("Claude: Network request failed - \(error)", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.networkError)
          return
        }
        
        guard let data = data else {
          Logger.error("Claude: No data received", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.networkError)
          return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
          continuation.resume(throwing: StoryGenerationError.networkError)
          return
        }
        
        switch httpResponse.statusCode {
        case 200:
          do {
            let responseContent = try self.parseClaudeResponse(data)
            continuation.resume(returning: responseContent)
          } catch {
            continuation.resume(throwing: error)
          }
        case 401:
          Logger.error("Claude: Invalid API key", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.serviceUnavailable)
        case 429:
          Logger.error("Claude: Rate limit exceeded", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.quotaExceeded)
        case 500...599:
          Logger.error("Claude: Server error (\(httpResponse.statusCode))", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.serviceUnavailable)
        default:
          Logger.error("Claude: Unexpected response (\(httpResponse.statusCode))", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.networkError)
        }
      }
      
      task.resume()
    }
  }
  
  private func parseClaudeResponse(_ data: Data) throws -> String {
    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let response = try decoder.decode(ClaudeResponse.self, from: data)
      
      // Extract text from content blocks
      var textContent = ""
      for content in response.content {
        if content.type == "text" {
          textContent += content.text
        }
      }
      
      if textContent.isEmpty {
        Logger.error("Claude: Empty response content", category: .storyGeneration)
        throw StoryGenerationError.generationFailed
      }
      
      return textContent.trimmingCharacters(in: .whitespacesAndNewlines)
      
    } catch {
      Logger.error("Claude: Failed to parse response - \(error)", category: .storyGeneration)
      throw StoryGenerationError.generationFailed
    }
  }
  
  private func createStory(from content: String, for profile: UserProfile, with options: StoryOptions) -> Story {
    let title = extractTitle(from: content) ?? generateFallbackTitle(for: profile, with: options)
    let storyContent = cleanContent(content)
    
    return Story(
      id: UUID(),
      title: title,
      content: storyContent,
      date: Date(),
      isFavorite: false,
      theme: options.effectiveTheme,
      length: options.length,
      characters: options.characters,
      ageRange: profile.babyStage,
      readingTime: estimateReadingTime(for: storyContent),
      tags: generateTags(for: profile, with: options)
    )
  }
  
  private func extractTitle(from content: String) -> String? {
    // Try to extract title from the first line if it looks like a title
    let lines = content.components(separatedBy: .newlines)
    guard let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines),
          !firstLine.isEmpty,
          firstLine.count < 100,
          !firstLine.contains(".") || firstLine.hasSuffix("...") else {
      return nil
    }
    
    return firstLine
  }
  
  private func generateFallbackTitle(for profile: UserProfile, with options: StoryOptions) -> String {
    return "\(profile.displayName)'s \(options.effectiveTheme) Adventure"
  }
  
  private func cleanContent(_ content: String) -> String {
    var cleaned = content
    
    // Remove title if it was extracted
    if let title = extractTitle(from: content) {
      cleaned = cleaned.replacingOccurrences(of: title, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Clean up extra whitespace
    cleaned = cleaned.replacingOccurrences(of: "\n\n\n+", with: "\n\n", options: .regularExpression)
    
    return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  private func estimateReadingTime(for content: String) -> TimeInterval {
    let wordCount = content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    let wordsPerMinute = 150.0
    return TimeInterval(Double(wordCount) / wordsPerMinute * 60)
  }
  
  private func generateTags(for profile: UserProfile, with options: StoryOptions) -> [String] {
    var tags = [options.effectiveTheme, profile.babyStage.rawValue, "AI Generated", profile.language.nativeName]
    
    // Add interest-based tags
    tags.append(contentsOf: profile.interests.prefix(2))
    
    // Add character tags
    tags.append(contentsOf: options.characters.prefix(2))
    
    return tags
  }
  
  private func getDailyTheme(for profile: UserProfile) -> String {
    // Start with base themes from StoryTheme enum
    var themes = StoryTheme.allCases.map { $0.rawValue }
    
    // Add age-appropriate themes
    switch profile.babyStage {
    case .pregnancy:
      themes.append(contentsOf: ["Gentle Dreams", "Peaceful Journey"])
    case .newborn, .infant:
      themes.append(contentsOf: ["Soft Lullaby", "Gentle Touch"])
    case .toddler:
      themes.append(contentsOf: ["Discovery Time", "Curious Explorer"])
    case .preschooler:
      themes.append(contentsOf: ["Big Kid Adventure", "Creative Play"])
    }
    
    return themes.randomElement() ?? StoryTheme.adventure.rawValue
  }
}

// MARK: - Claude API Models

private struct ClaudeRequest: Codable {
  let model: String
  let messages: [ClaudeMessage]
  let maxTokens: Int
  let temperature: Double
}

private struct ClaudeMessage: Codable {
  let role: String
  let content: String
}

private struct ClaudeResponse: Codable {
  let content: [ClaudeContent]
}

private struct ClaudeContent: Codable {
  let type: String
  let text: String
}

// MARK: - Configuration Extension

extension AnthropicClaudeStoryGenerationService {
  
  /// Create a Claude service with API key from configuration
  /// - Returns: Configured Claude service or nil if no API key is available
  static func createWithStoredAPIKey() -> AnthropicClaudeStoryGenerationService? {
    // Get API key from configuration (xcconfig -> Info.plist)
    if let apiKey = AnthropicAPIConfig.apiKey, !apiKey.isEmpty {
      return AnthropicClaudeStoryGenerationService(apiKey: apiKey)
    }
    
    Logger.error("Claude: No API key found in configuration", category: .storyGeneration)
    return nil
  }
}
