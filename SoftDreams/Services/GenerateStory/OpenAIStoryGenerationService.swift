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
  private var storyHistory: [String] = [] // Track recent story combinations
  private let maxHistorySize = 15 // Keep last 15 story combinations
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
    self.temperature = max(temperature, 0.9) // Ensure minimum creativity
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
      // Build the enhanced prompt based on profile and options
      let prompt = buildPrompt(for: profile, with: options)
      
      // Log request summary
      Logger.info("OpenAI: Request summary - Model: \(model), Max Tokens: \(maxTokens), Temperature: \(temperature), Profile: \(profile.displayName), Theme: \(options.effectiveTheme), Length: \(options.length)", category: .storyGeneration)
      
      let response = try await makeOpenAIRequest(prompt: prompt)
      let story = createStory(from: response, for: profile, with: options)
      
      // Track this story's theme and title for future uniqueness
      trackStoryElement("theme:\(options.effectiveTheme)")
      trackStoryElement("title_pattern:\(extractTitlePattern(story.title))")
      
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
    let developmentalContext = getDevelopmentalContext(for: profile.babyStage, requestedLength: options.length)
    let educationalObjectives = getEducationalObjectives(for: profile.babyStage)
    let uniqueElements = generateUniqueStoryElements(for: profile, with: options)
    
    return """
    # Expert Children's Story Writer
    
    You are an expert children's story writer specializing in developmentally appropriate, educational storytelling for children aged 0-5 years.
    
    ## Task
    Create a personalized bedtime story in \(profile.language.nativeName) language only.
    
    ## Child Profile
    - **Name**: \(profile.displayName)
    - **Age/Stage**: \(getAgeDescription(for: profile)) 
    - **Gender**: \(getGenderDescription(for: profile))
    - **Interests**: \(profile.interests.isEmpty ? "Not specified" : profile.interests.joined(separator: ", "))
    - **Language**: \(profile.language.nativeName) (write EXCLUSIVELY in this language)
    
    ## Story Requirements
    - **Theme**: \(options.effectiveTheme)
    - **Target Length**: \(getLengthDescription(for: options.length, stage: profile.babyStage))
    - **Characters**: \(options.characters.isEmpty ? "Create age-appropriate characters" : options.characters.joined(separator: ", "))
    
    ## Developmental Context
    \(developmentalContext.description)
    **Child's Attention Span**: \(developmentalContext.attentionSpan)
    **Optimal Story Length**: \(developmentalContext.adjustedLength)
    **Key Development Areas**: \(developmentalContext.developmentAreas.joined(separator: ", "))
    
    ## Educational Objectives
    \(educationalObjectives.joined(separator: "\n"))
    
    ## Creative Elements (Use These)
    - **Setting**: \(uniqueElements.setting)
    - **Plot Device**: \(uniqueElements.plotDevice)
    - **Narrative Style**: \(uniqueElements.narrative)
    - **Mood**: \(uniqueElements.mood)
    
    ## Story Structure Guidelines
    
    ### Beginning (25% of target length)
    - Introduce \(profile.displayName) in a relatable situation
    - Establish the setting using sensory details appropriate for \(profile.babyStage.displayName)
    - Present a gentle challenge or opportunity for discovery matching attention span
    
    ### Middle (50% of target length)
    - Develop the adventure with \(profile.babyStage.displayName)-appropriate obstacles
    - Include interactive moments (what would \(profile.displayName) do?)
    - Integrate learning opportunities from educational objectives above
    - Use repetitive elements for engagement within the \(options.length.rawValue) format
    
    ### End (25% of target length)
    - Resolve the story with \(profile.displayName)'s growth/success
    - Include a gentle lesson matching developmental stage
    - End with a peaceful, bedtime-appropriate conclusion
    - Ensure total story matches the \(options.length.rawValue) length requirement
    
    ## Language & Style Requirements
    - Write EXCLUSIVELY in \(profile.language.nativeName) - no other languages
    - Use vocabulary appropriate for \(profile.babyStage.displayName)
    - Include rich sensory descriptions (colors, sounds, textures, smells)
    - Use appropriate pronouns: \(getGenderDescription(for: profile))
    - Incorporate rhythm and repetition for engagement
    \(profile.language.code == "vi" ? "- Include Vietnamese cultural elements and values naturally" : "- Include culturally relevant elements when appropriate")
    
    ## Quality Standards
    - NO scary, sad, or negative content
    - Encourage positive values (kindness, curiosity, courage, friendship)
    - Make \(profile.displayName) the capable, brave main character
    - Include at least 3 sensory details appropriate for \(profile.babyStage.displayName)
    - End with a sentence that promotes calm and sleepiness
    - **CRITICAL LENGTH REQUIREMENT**: Write \(getWordCountGuidance(for: options.length, stage: profile.babyStage))
    - **ATTENTION SPAN PRIORITY**: The story MUST respect the \(profile.babyStage.displayName) attention span over user length preference
    
    Create the complete story now, ensuring it perfectly matches the developmental needs and attention span requirements above.
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
  
  private func getLengthDescription(for length: StoryLength, stage: BabyStage) -> String {
    let baseDescription = length.aiPromptDescription
    
    // Add developmental context to length guidance
    switch (length, stage) {
    case (.short, .pregnancy), (.short, .newborn):
      return "\(baseDescription) - Brief, soothing narrative perfect for bonding moments"
    case (.short, .infant):
      return "\(baseDescription) - Simple story with repetitive elements and sensory focus"
    case (.short, .toddler):
      return "\(baseDescription) - Quick adventure with clear problem-solving elements"
    case (.short, .preschooler):
      return "\(baseDescription) - Concise story with moral lesson and character development"
      
    case (.medium, .pregnancy), (.medium, .newborn):
      return "\(baseDescription) - Well-paced narrative with emotional depth for parent reading"
    case (.medium, .infant):
      return "\(baseDescription) - Engaging story with cause-effect patterns and vocabulary building"
    case (.medium, .toddler):
      return "\(baseDescription) - Balanced adventure with social skills and independence themes"
    case (.medium, .preschooler):
      return "\(baseDescription) - Rich narrative with complex themes and pre-literacy elements"
      
    case (.long, .pregnancy), (.long, .newborn):
      return "\(baseDescription) - Extended narrative for relaxed reading sessions with detailed imagery"
    case (.long, .infant):
      return "\(baseDescription) - Comprehensive story with multiple sensory experiences and concepts"
    case (.long, .toddler):
      return "\(baseDescription) - Full adventure with multiple challenges and learning opportunities"
    case (.long, .preschooler):
      return "\(baseDescription) - Complex story with multiple characters, moral depth, and educational content"
    }
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
  
  private func getGenderDescription(for profile: UserProfile) -> String {
    switch profile.gender {
    case .male:
      return "boy - use male pronouns (he/him/his)"
    case .female:
      return "girl - use female pronouns (she/her/hers)"
    case .notSpecified:
      return "child - use neutral pronouns (they/them/their) or the child's name"
    }
  }
  
  private func getDevelopmentalContext(for stage: BabyStage, requestedLength: StoryLength) -> (description: String, attentionSpan: String, developmentAreas: [String], adjustedLength: String) {
    let baseContext = getBaseDevelopmentalContext(for: stage)
    let adjustedLength = getOptimalLength(for: stage, requested: requestedLength)
    
    return (
      description: baseContext.description,
      attentionSpan: baseContext.attentionSpan,
      developmentAreas: baseContext.developmentAreas,
      adjustedLength: adjustedLength
    )
  }
  
  private func getBaseDevelopmentalContext(for stage: BabyStage) -> (description: String, attentionSpan: String, developmentAreas: [String]) {
    switch stage {
    case .pregnancy:
      return (
        description: "This story is for an unborn baby, meant to be read by parents during pregnancy to promote bonding.",
        attentionSpan: "10-15 minutes (parent reading time)",
        developmentAreas: ["Prenatal bonding", "Emotional connection", "Anticipation building"]
      )
    case .newborn:
      return (
        description: "Newborns respond to rhythm, repetition, and soothing sounds. Focus on gentle, rhythmic language.",
        attentionSpan: "2-3 minutes",
        developmentAreas: ["Auditory development", "Language exposure", "Comfort and security"]
      )
    case .infant:
      return (
        description: "Infants are developing object permanence and enjoy cause-and-effect relationships.",
        attentionSpan: "3-5 minutes",
        developmentAreas: ["Sensory exploration", "Cause and effect", "Social interaction", "Basic emotions"]
      )
    case .toddler:
      return (
        description: "Toddlers are exploring independence, learning basic social skills, and developing language rapidly.",
        attentionSpan: "5-10 minutes",
        developmentAreas: ["Language development", "Independence", "Social skills", "Emotional regulation", "Problem solving"]
      )
    case .preschooler:
      return (
        description: "Preschoolers can follow complex stories, understand moral lessons, and enjoy imaginative play.",
        attentionSpan: "10-15 minutes",
        developmentAreas: ["Complex language", "Moral reasoning", "Imagination", "Pre-literacy skills", "Emotional intelligence"]
      )
    }
  }
  
  private func getOptimalLength(for stage: BabyStage, requested: StoryLength) -> String {
    // Determine what length is actually appropriate for this developmental stage
    let maxAppropriateLengths: [BabyStage: StoryLength] = [
      .pregnancy: .long,    // Parents can read longer stories
      .newborn: .short,     // 2-3 min attention span
      .infant: .medium,     // 3-5 min attention span  
      .toddler: .medium,    // 5-10 min attention span
      .preschooler: .long   // 10-15 min attention span
    ]
    
    let maxAppropriate = maxAppropriateLengths[stage] ?? .medium
    
    // If requested length exceeds developmental capacity, adjust down with explanation
    if requested.rawValue.count > maxAppropriate.rawValue.count {
      switch (stage, requested) {
      case (.newborn, .medium), (.newborn, .long):
        return "Short story (adjusted from \(requested.rawValue) to match 2-3 minute attention span)"
      case (.infant, .long):
        return "Medium story (adjusted from long to match 3-5 minute attention span)"
      case (.toddler, .long):
        return "Medium story (recommended over long for 5-10 minute attention span)"
      default:
        return requested.aiPromptDescription
      }
    }
    
    return requested.aiPromptDescription
  }
  
  private func getEducationalObjectives(for stage: BabyStage) -> [String] {
    switch stage {
    case .pregnancy:
      return [
        "- Create emotional connection between parent and unborn child",
        "- Establish positive expectations for the future",
        "- Introduce the child's name and family context"
      ]
    case .newborn:
      return [
        "- Provide auditory stimulation through varied intonation",
        "- Create association between story time and comfort",
        "- Use repetitive, soothing language patterns"
      ]
    case .infant:
      return [
        "- Introduce basic concepts (colors, sounds, textures)",
        "- Demonstrate simple cause-and-effect relationships",
        "- Encourage sensory exploration through descriptive language",
        "- Build vocabulary with naming objects and actions"
      ]
    case .toddler:
      return [
        "- Teach basic social skills (sharing, kindness, cooperation)",
        "- Introduce problem-solving strategies",
        "- Expand vocabulary with descriptive adjectives",
        "- Practice emotional recognition and naming",
        "- Encourage independence and confidence"
      ]
    case .preschooler:
      return [
        "- Develop pre-literacy skills (story structure, sequencing)",
        "- Teach complex social-emotional concepts",
        "- Introduce basic moral reasoning",
        "- Expand imagination and creative thinking",
        "- Build attention span and listening skills",
        "- Practice memory and comprehension"
      ]
    }
  }
  
  private func getWordCountGuidance(for length: StoryLength, stage: BabyStage) -> String {
    // Get developmentally appropriate word counts, respecting attention spans
    let adjustedCounts: (min: Int, max: Int) = {
      switch (stage, length) {
      // Pregnancy - parent reading, can be longer
      case (.pregnancy, .short): return (150, 300)
      case (.pregnancy, .medium): return (300, 600)
      case (.pregnancy, .long): return (600, 1000)
      
      // Newborn - max 2-3 minutes, very short regardless of request
      case (.newborn, .short): return (80, 150)
      case (.newborn, .medium): return (80, 150)  // Adjusted down
      case (.newborn, .long): return (80, 150)    // Adjusted down
      
      // Infant - max 3-5 minutes
      case (.infant, .short): return (100, 200)
      case (.infant, .medium): return (200, 350)
      case (.infant, .long): return (200, 350)    // Adjusted down
      
      // Toddler - max 5-10 minutes  
      case (.toddler, .short): return (120, 250)
      case (.toddler, .medium): return (250, 450)
      case (.toddler, .long): return (350, 450)   // Slightly adjusted
      
      // Preschooler - can handle full lengths
      case (.preschooler, .short): return (150, 300)
      case (.preschooler, .medium): return (300, 600)
      case (.preschooler, .long): return (600, 900)
      }
    }()
    
    return "approximately \(adjustedCounts.min)-\(adjustedCounts.max) words total"
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
  
  // MARK: - Uniqueness Enhancement Methods
  
  private func generateUniqueStoryElements(for profile: UserProfile, with options: StoryOptions) -> (setting: String, plotDevice: String, narrative: String, mood: String) {
    let settings = getRandomSettings(for: profile.babyStage)
    let plotDevices = getRandomPlotDevices(for: profile.babyStage)
    let narratives = getRandomNarrativeStyles()
    let moods = getRandomMoods(for: profile.babyStage)
    
    // Find elements not recently used
    let availableSettings = settings.filter { !isRecentlyUsed("setting:\($0)") }
    let availablePlotDevices = plotDevices.filter { !isRecentlyUsed("plot:\($0)") }
    let availableNarratives = narratives.filter { !isRecentlyUsed("narrative:\($0)") }
    let availableMoods = moods.filter { !isRecentlyUsed("mood:\($0)") }
    
    // Use fresh elements if available, fallback to any if all recently used
    let selectedSetting = availableSettings.randomElement() ?? settings.randomElement() ?? "magical garden"
    let selectedPlotDevice = availablePlotDevices.randomElement() ?? plotDevices.randomElement() ?? "discovery"
    let selectedNarrative = availableNarratives.randomElement() ?? narratives.randomElement() ?? "adventure"
    let selectedMood = availableMoods.randomElement() ?? moods.randomElement() ?? "cheerful"
    
    // Track usage
    trackStoryElement("setting:\(selectedSetting)")
    trackStoryElement("plot:\(selectedPlotDevice)")
    trackStoryElement("narrative:\(selectedNarrative)")
    trackStoryElement("mood:\(selectedMood)")
    
    return (
      setting: "- Setting: \(selectedSetting)",
      plotDevice: "- Story device: \(selectedPlotDevice)",
      narrative: "- Narrative style: \(selectedNarrative)",
      mood: "- Story mood: \(selectedMood)"
    )
  }
  
  private func isRecentlyUsed(_ element: String) -> Bool {
    return storyHistory.contains(element)
  }
  
  private func trackStoryElement(_ element: String) {
    // Add to history
    storyHistory.append(element)
    
    // Keep only recent elements (limit memory usage)
    if storyHistory.count > maxHistorySize {
      storyHistory.removeFirst(storyHistory.count - maxHistorySize)
    }
  }
  
  private func getRandomSettings(for stage: BabyStage) -> [String] {
    let baseSettings = [
      "enchanted forest with singing trees",
      "cozy library with talking books",
      "magical bakery with dancing ingredients",
      "underwater kingdom with friendly sea creatures",
      "cloud city with rainbow bridges",
      "music box world with tiny dancers",
      "garden where flowers tell jokes",
      "treehouse village in the sky",
      "candy kingdom with chocolate rivers",
      "art studio where paintings come alive"
    ]
    
    switch stage {
    case .pregnancy, .newborn:
      return ["peaceful meadow with gentle butterflies", "warm nest in the clouds", "soft blanket fort"]
    case .infant:
      return ["colorful playroom with bouncing balls", "musical toy chest", "sunny nursery"]
    case .toddler:
      return baseSettings.prefix(5) + ["playground with magical swings", "sandbox with buried treasures"]
    case .preschooler:
      return baseSettings + ["space station with friendly aliens", "time machine workshop", "dinosaur valley"]
    }
  }
  
  private func getRandomPlotDevices(for stage: BabyStage) -> [String] {
    let baseDevices = [
      "finding a magical key that opens special doors",
      "helping a lost animal find its way home",
      "solving a gentle mystery with friends",
      "learning a new skill from a wise mentor",
      "discovering a hidden talent",
      "going on a treasure hunt for kindness",
      "teaching someone something important",
      "fixing something that's broken with creativity"
    ]
    
    switch stage {
    case .pregnancy, .newborn:
      return ["gentle exploration", "peaceful discovery", "warm encounters"]
    case .infant:
      return ["sensory exploration", "cause and effect learning", "social interaction"]
    case .toddler:
      return baseDevices.prefix(4) + ["learning to share", "overcoming a small fear"]
    case .preschooler:
      return baseDevices + ["time travel adventure", "becoming a superhero helper", "scientific discovery"]
    }
  }
  
  private func getRandomNarrativeStyles() -> [String] {
    return [
      "tell the story like a gentle lullaby",
      "use lots of sound effects and onomatopoeia",
      "include interactive questions for the listener",
      "tell it as a series of discoveries",
      "use rhythmic, poem-like language",
      "include sensory descriptions (touch, smell, taste)",
      "tell it as a conversation between characters",
      "use counting or patterns in the storytelling",
      "include silly wordplay and rhymes",
      "tell it as a step-by-step adventure"
    ]
  }
  
  private func getRandomMoods(for stage: BabyStage) -> [String] {
    let baseMoods = [
      "cheerful and optimistic",
      "curious and wonder-filled",
      "warm and comforting",
      "playful and silly",
      "gentle and soothing",
      "exciting but safe",
      "magical and dreamy",
      "cozy and intimate"
    ]
    
    switch stage {
    case .pregnancy, .newborn:
      return ["peaceful and serene", "gentle and loving", "soft and dreamy"]
    case .infant:
      return ["bright and cheerful", "calm and soothing", "gentle and playful"]
    case .toddler, .preschooler:
      return baseMoods
    }
  }
  
  private func getCreativityInstructions() -> String {
    let instructions = [
      "- BE HIGHLY CREATIVE: Invent unique details, unexpected (but safe) plot twists, and original elements",
      "- AVOID CLICHÉS: Don't use common fairy tale tropes - create something fresh and original",
      "- ADD SURPRISE ELEMENTS: Include unexpected but delightful moments that will surprise and engage",
      "- CREATE UNIQUE CHARACTERS: Even familiar animals or objects should have distinctive personalities",
      "- INVENT ORIGINAL DETAILS: Create specific, imaginative details that make this story one-of-a-kind",
      "- USE UNEXPECTED COMBINATIONS: Mix different themes, settings, or ideas in creative ways",
      "- INCLUDE SENSORY SURPRISES: Add unexpected sounds, textures, colors, or sensations",
      "- CREATE ORIGINAL DIALOGUE: Characters should speak in unique, memorable ways"
    ]
    
    return instructions.randomElement() ?? instructions[0]
  }
  
  private func extractTitlePattern(_ title: String) -> String {
    // Extract pattern from title to avoid similar titles
    // e.g., "Emma's Adventure" -> "[name]'s Adventure"
    let pattern = title.replacingOccurrences(of: "\\b[A-Z][a-z]+(?='s)\\b", with: "[name]", options: .regularExpression)
    return pattern
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
}
