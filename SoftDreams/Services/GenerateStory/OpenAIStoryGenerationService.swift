import Foundation

// MARK: - OpenAI Story Generation Service
/// OpenAI implementation of StoryGenerationServiceProtocol for AI-powered story generation
class OpenAIStoryGenerationService: StoryGenerationServiceProtocol, @unchecked Sendable {
  
  // MARK: - Properties
  private let apiKey: String
  private let baseURL: String
  private let model: String
  private let maxTokens: Int
  private let temperature: Double
  private let session: URLSession
  
  // MARK: - Initialization
  init(
    apiKey: String,
    model: String = "gpt-3.5-turbo",
    maxTokens: Int = 1500,
    temperature: Double = 0.85,
    session: URLSession = .shared,
    baseURL: String? = nil
  ) {
    self.apiKey = apiKey
    self.model = model
    self.maxTokens = maxTokens
    self.temperature = temperature
    self.session = session
    
    // Use provided baseURL or get from configuration
    if let providedURL = baseURL {
      self.baseURL = providedURL
    } else {
      let configuredBaseURL = APIConfig.openAIBaseUrl
      // Ensure we have the full chat/completions endpoint
      if configuredBaseURL.hasSuffix("/chat/completions") {
        self.baseURL = configuredBaseURL
      } else {
        self.baseURL = configuredBaseURL + "/chat/completions"
      }
    }
    
    print("OpenAIStoryGenerationService initialized with baseURL: \(self.baseURL)")
  }
  
  // MARK: - StoryGenerationServiceProtocol Implementation
  
  func generateStory(for profile: UserProfile, with options: StoryOptions) async throws -> Story {
    Logger.info("OpenAI: Starting story generation for \(profile.displayName)", category: .storyGeneration)
    
    // Validate inputs
    guard canGenerateStory(for: profile, with: options) else {
      throw StoryGenerationError.invalidProfile
    }
    guard !apiKey.isEmpty else {
      Logger.error("OpenAI: API key is missing", category: .storyGeneration)
      throw StoryGenerationError.serviceUnavailable
    }
    
    do {
      // Build the prompt based on profile and options
      // get random prompt from multiple variations
      let stablePrompt = buildPrompt(for: profile, with: options)
      let prompts = [
        stablePrompt,
        buildPrompt1(for: profile, with: options),
        buildPrompt2(for: profile, with: options),
        buildPrompt3(for: profile, with: options),
        buildPrompt4(for: profile, with: options),
        buildPrompt5(for: profile, with: options),
        buildPrompt6(for: profile, with: options),
        buildPrompt7(for: profile, with: options),
        buildPrompt8(for: profile, with: options),
        buildPrompt9(for: profile, with: options),
        buildPrompt10(for: profile, with: options)
      ]
      let prompt = prompts.randomElement() ?? stablePrompt
      
      // Log request summary
      Logger.info("OpenAI: Request summary - Model: \(model), Max Tokens: \(maxTokens), Temperature: \(temperature), Profile: \(profile.displayName), Theme: \(options.effectiveTheme), Length: \(options.length)", category: .storyGeneration)
      
      let response = try await makeOpenAIRequest(prompt: prompt)
      let story = createStory(from: response, for: profile, with: options)
      
      Logger.info("OpenAI: Story generation completed - '\(story.title)'", category: .storyGeneration)
      return story
      
    } catch let error as StoryGenerationError {
      throw error
    } catch {
      Logger.error("OpenAI: Story generation failed - \(error.localizedDescription)", category: .storyGeneration)
      throw StoryGenerationError.generationFailed
    }
  }
   func generateDailyStory(for profile: UserProfile) async throws -> Story {
    var defaultOptions = StoryOptions(
      length: .medium,
      theme: getDailyTheme(for: profile),
      characters: []
    )
    
    // Apply predefined characters when no characters are specified
    defaultOptions.applyPredefinedCharactersIfNeeded(for: profile)

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
    - REQUIRED LANGUAGE: \(languageInstruction)
    - Story should be appropriate for \(ageDescription)
    \(interestsText)\(charactersText)
    
    CRITICAL LANGUAGE REQUIREMENT:
    - The ENTIRE story MUST be written ONLY in \(profile.language.nativeName) language
    - Do NOT mix languages - use ONLY \(profile.language.nativeName)
    - Every word, sentence, and dialogue must be in \(profile.language.nativeName)
    
    Guidelines:
    - Write the complete story exclusively in \(profile.language.nativeName) language
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
  private func makeOpenAIRequest(prompt: String) async throws -> String {
    guard let url = URL(string: baseURL) else {
      throw StoryGenerationError.serviceUnavailable
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody = OpenAIRequest(
      model: model,
      messages: [
        OpenAIMessage(role: "system", content: "You are a creative children's story writer who creates personalized, age-appropriate stories."),
        OpenAIMessage(role: "user", content: prompt)
      ],
      maxTokens: maxTokens,
      temperature: temperature
    )
    
    do {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let requestData = try encoder.encode(requestBody)
      request.httpBody = requestData
      
      // Log the full request details
      Logger.info("OpenAI: Making request to \(baseURL)", category: .storyGeneration)
      Logger.info("OpenAI: Request method: \(request.httpMethod ?? "Unknown")", category: .storyGeneration)
      
      // Log headers (excluding sensitive Authorization header)
      if let headers = request.allHTTPHeaderFields {
        let sanitizedHeaders = headers.mapValues { key in
          return key.lowercased().contains("authorization") ? "[REDACTED]" : headers[key] ?? ""
        }
        Logger.info("OpenAI: Request headers: \(sanitizedHeaders)", category: .storyGeneration)
      }
      
      // Log the full request body (formatted JSON)
      if let requestString = String(data: requestData, encoding: .utf8) {
        Logger.info("OpenAI: Request body:\n\(requestString)", category: .storyGeneration)
      }
      
    } catch {
      Logger.error("OpenAI: Failed to encode request - \(error)", category: .storyGeneration)
      throw StoryGenerationError.generationFailed
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
          Logger.error("OpenAI: Network request failed - \(error)", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.networkError)
          return
        }
        
        guard let data = data else {
          Logger.error("OpenAI: No data received", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.networkError)
          return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
          continuation.resume(throwing: StoryGenerationError.networkError)
          return
        }
        
        Logger.info("OpenAI: Received HTTP status code: \(httpResponse.statusCode)", category: .storyGeneration)
        
        // Log response headers for debugging
        Logger.info("OpenAI: Response headers: \(httpResponse.allHeaderFields)", category: .storyGeneration)
        
        // Log response body for all cases (but truncate if too long for successful responses)
        if let responseString = String(data: data, encoding: .utf8) {
          if httpResponse.statusCode == 200 {
            // For successful responses, truncate if very long to avoid log spam
            let truncatedResponse = responseString.count > 2000 ?
            String(responseString.prefix(2000)) + "... [truncated]" : responseString
            Logger.info("OpenAI: Response body: \(truncatedResponse)", category: .storyGeneration)
          } else {
            // For error responses, log the full response
            Logger.info("OpenAI: Full response body: \(responseString)", category: .storyGeneration)
          }
        }
        
        switch httpResponse.statusCode {
        case 200:
          do {
            let responseContent = try self.parseOpenAIResponse(data)
            continuation.resume(returning: responseContent)
          } catch {
            continuation.resume(throwing: error)
          }
        case 401:
          Logger.error("OpenAI: Invalid API key (401)", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.serviceUnavailable)
        case 429:
          Logger.error("OpenAI: Rate limit exceeded (429)", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.quotaExceeded)
        case 500...599:
          Logger.error("OpenAI: Server error (\(httpResponse.statusCode))", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.serviceUnavailable)
        default:
          Logger.error("OpenAI: Unexpected response (\(httpResponse.statusCode))", category: .storyGeneration)
          continuation.resume(throwing: StoryGenerationError.networkError)
        }
      }
      
      task.resume()
    }
  }
  
  private func parseOpenAIResponse(_ data: Data) throws -> String {
    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let response = try decoder.decode(OpenAIResponse.self, from: data)
      
      guard let choice = response.choices.first,
            let content = choice.message.content else {
        Logger.error("OpenAI: Empty response content", category: .storyGeneration)
        throw StoryGenerationError.generationFailed
      }
      
      return content.trimmingCharacters(in: .whitespacesAndNewlines)
      
    } catch {
      Logger.error("OpenAI: Failed to parse response - \(error)", category: .storyGeneration)
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

// MARK: - OpenAI API Models

private struct OpenAIRequest: Codable {
  let model: String
  let messages: [OpenAIMessage]
  let maxTokens: Int
  let temperature: Double
}

private struct OpenAIMessage: Codable {
  let role: String
  let content: String?
}

private struct OpenAIResponse: Codable {
  let choices: [OpenAIChoice]
}

private struct OpenAIChoice: Codable {
  let message: OpenAIMessage
}

// MARK: - Configuration Extension

extension OpenAIStoryGenerationService {
  /// experiment prompt
  
  // MARK: - Multiple Prompt Variations
  
  private func buildPrompt1(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    CRITICAL LANGUAGE REQUIREMENT: Write the ENTIRE story ONLY in \(profile.language.nativeName) language.
    
    Write a magical bedtime story for a child named \(profile.displayName), who is a \(getAgeDescription(for: profile)). The story should focus on the theme "\(options.effectiveTheme)" and be written EXCLUSIVELY in \(profile.language.nativeName). 
    
    IMPORTANT: Every single word, sentence, and dialogue MUST be in \(profile.language.nativeName) only - do NOT mix languages.
    
    Use simple, age-appropriate language, make the child the main character, and end with a comforting, happy conclusion. \(profile.interests.isEmpty ? "" : "The child enjoys \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Include these characters: \(options.characters.joined(separator: ", ")).") The story should be \(getLengthDescription(for: options.length)).
    """
  }
  
  private func buildPrompt2(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    LANGUAGE REQUIREMENT: Write EXCLUSIVELY in \(profile.language.nativeName) - do NOT use any other language.
    
    Create a personalized story for \(profile.displayName), a \(getAgeDescription(for: profile)), with the theme "\(options.effectiveTheme)". Write ONLY in \(profile.language.nativeName) using gentle, child-friendly words. Every word must be in \(profile.language.nativeName).
    
    Make sure the story is \(getLengthDescription(for: options.length)), imaginative, and features \(profile.displayName) as the main character. \(profile.interests.isEmpty ? "" : "Incorporate interests such as \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Add these characters: \(options.characters.joined(separator: ", ")).") End with a positive message.
    """
  }
  
  private func buildPrompt3(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    MANDATORY: Write the entire story in \(profile.language.nativeName) language ONLY - no other languages allowed.
    
    Tell a bedtime story to a child named \(profile.displayName), who is a \(getAgeDescription(for: profile)). The story should be about "\(options.effectiveTheme)", written EXCLUSIVELY in \(profile.language.nativeName), and \(getLengthDescription(for: options.length)). 
    
    Use simple words, include sensory details, and ensure the story is uplifting. \(profile.interests.isEmpty ? "" : "Mention the child's interests: \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Feature these characters: \(options.characters.joined(separator: ", ")).") The story should end peacefully. Remember: use ONLY \(profile.language.nativeName).
    """
  }
  
  private func buildPrompt4(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    IMPORTANT LANGUAGE INSTRUCTION: The entire story MUST be written ONLY in \(profile.language.nativeName) - no exceptions.
    
    Compose a creative, age-appropriate story for \(profile.displayName) (\(getAgeDescription(for: profile))). The theme is "\(options.effectiveTheme)", and the story should be written EXCLUSIVELY in \(profile.language.nativeName). Use engaging, simple language and make the story \(getLengthDescription(for: options.length)). 
    
    Do not mix any other language - write everything in \(profile.language.nativeName) only. \(profile.interests.isEmpty ? "" : "Include elements related to \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Characters to include: \(options.characters.joined(separator: ", ")).") The story should be gentle and have a happy ending.
    """
  }
  
  private func buildPrompt5(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    LANGUAGE REQUIREMENT: The complete story must be written EXCLUSIVELY in \(profile.language.nativeName) - no language mixing allowed.
    
    Tell a delightful story for a child named \(profile.displayName), who is a \(getAgeDescription(for: profile)). The story should revolve around "\(options.effectiveTheme)", be \(getLengthDescription(for: options.length)), and written ONLY in \(profile.language.nativeName). 
    
    Every word, sentence, and dialogue must be in \(profile.language.nativeName). \(profile.interests.isEmpty ? "" : "Incorporate the child's interests: \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Include these characters: \(options.characters.joined(separator: ", ")).") Use positive, simple language and finish with a comforting conclusion.
    """
  }
  
  private func buildPrompt6(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    CRITICAL: Write the entire story EXCLUSIVELY in \(profile.language.nativeName) - no other languages permitted.
    
    Write a gentle, imaginative story for \(profile.displayName) (\(getAgeDescription(for: profile))). The theme is "\(options.effectiveTheme)", and the story should be \(getLengthDescription(for: options.length)). 
    
    Use ONLY \(profile.language.nativeName) and ensure the language is suitable for children. Do not mix languages - every word must be in \(profile.language.nativeName). \(profile.interests.isEmpty ? "" : "Mention interests like \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Add these characters: \(options.characters.joined(separator: ", ")).") The story should be uplifting and end happily.
    """
  }
  
  private func buildPrompt7(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    LANGUAGE REQUIREMENT: Write EXCLUSIVELY in \(profile.language.nativeName) - do NOT use any other language.
    
    Create a bedtime story for \(profile.displayName), a \(getAgeDescription(for: profile)), themed "\(options.effectiveTheme)". Write in \(profile.language.nativeName) using simple, child-friendly language. The story should be \(getLengthDescription(for: options.length)). 
    
    Every word must be in \(profile.language.nativeName) only. \(profile.interests.isEmpty ? "" : "Include the child's interests: \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Characters: \(options.characters.joined(separator: ", ")).") Make sure the story is positive and ends with a gentle message.
    """
  }
  
  private func buildPrompt8(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    CRITICAL LANGUAGE INSTRUCTION: Write the ENTIRE story ONLY in \(profile.language.nativeName) language - no mixing allowed.
    
    Please write a personalized, age-appropriate story for \(profile.displayName) (\(getAgeDescription(for: profile))). The theme is "\(options.effectiveTheme)", and the story should be \(getLengthDescription(for: options.length)). Use EXCLUSIVELY \(profile.language.nativeName) and simple language. 
    
    Every single word must be in \(profile.language.nativeName) - do not use any other language. \(profile.interests.isEmpty ? "" : "Incorporate interests: \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Include these characters: \(options.characters.joined(separator: ", ")).") The story should be imaginative, gentle, and have a happy ending.
    """
  }
  
  private func buildPrompt9(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    CRITICAL LANGUAGE REQUIREMENT: Write the ENTIRE story ONLY in \(profile.language.nativeName) language - no mixing permitted.
    
    Compose a story for a child named \(profile.displayName), who is a \(getAgeDescription(for: profile)). The story should be about "\(options.effectiveTheme)", written EXCLUSIVELY in \(profile.language.nativeName), and be \(getLengthDescription(for: options.length)). 
    
    Every word, sentence, and dialogue must be in \(profile.language.nativeName) only. \(profile.interests.isEmpty ? "" : "Mention interests such as \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Characters to include: \(options.characters.joined(separator: ", ")).") Use positive, simple language and end with a comforting message.
    """
  }
  
  private func buildPrompt10(for profile: UserProfile, with options: StoryOptions) -> String {
    """
    MANDATORY LANGUAGE INSTRUCTION: Write the complete story EXCLUSIVELY in \(profile.language.nativeName) - no other languages allowed.
    
    Imagine you are a storyteller for children. Write a story for \(profile.displayName) (\(getAgeDescription(for: profile))) with the theme "\(options.effectiveTheme)". The story should be \(getLengthDescription(for: options.length)), written ONLY in \(profile.language.nativeName), and use simple, age-appropriate language. 
    
    Every word must be in \(profile.language.nativeName) - do not mix any other language. \(profile.interests.isEmpty ? "" : "Include the child's interests: \(profile.interests.joined(separator: ", ")).") \(options.characters.isEmpty ? "" : "Add these characters: \(options.characters.joined(separator: ", ")).") Make the story gentle, imaginative, and end on a positive note.
    """
  }
  // ...existing code...
}
