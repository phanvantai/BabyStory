import Foundation
import os.log

// MARK: - Logger
/// Simple logging utility for debugging and monitoring app behavior
struct Logger {
  
  // MARK: - Log Categories
  enum Category: String {
    case userProfile = "UserProfile"
    case storage = "Storage"
    case storyGeneration = "StoryGeneration"
    case onboarding = "Onboarding"
    case settings = "Settings"
    case general = "General"
    
    var subsystem: String {
      return "com.randomtech.BabyStory"
    }
  }
  
  // MARK: - Log Levels
  enum Level {
    case debug
    case info
    case warning
    case error
  }
  
  // MARK: - Private Properties
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
  }()
  
  // MARK: - Public Methods
  static func log(
    _ message: String,
    category: Category = .general,
    level: Level = .info,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    #if DEBUG
    let timestamp = dateFormatter.string(from: Date())
    let filename = (file as NSString).lastPathComponent
    let levelString = levelIcon(for: level)
    
    print("[\(timestamp)] \(levelString) [\(category.rawValue)] \(filename):\(line) \(function) - \(message)")
    #endif
  }
  
  // MARK: - Convenience Methods
  static func debug(
    _ message: String,
    category: Category = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    log(message, category: category, level: .debug, file: file, function: function, line: line)
  }
  
  static func info(
    _ message: String,
    category: Category = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    log(message, category: category, level: .info, file: file, function: function, line: line)
  }
  
  static func warning(
    _ message: String,
    category: Category = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    log(message, category: category, level: .warning, file: file, function: function, line: line)
  }
  
  static func error(
    _ message: String,
    category: Category = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    log(message, category: category, level: .error, file: file, function: function, line: line)
  }
  
  // MARK: - Profile Specific Logging
  static func logUserProfile(_ profile: UserProfile?, action: String = "Loaded") {
    guard let profile = profile else {
      warning("User profile is nil", category: .userProfile)
      return
    }
    
    let ageInfo: String
    if let age = profile.currentAge {
      ageInfo = "\(age) years old"
    } else if profile.isPregnancy {
      ageInfo = "Pregnancy"
    } else {
      ageInfo = "Age unknown"
    }
    
    let interestsInfo = profile.interests.isEmpty ? "No interests" : "\(profile.interests.count) interests: \(profile.interests.joined(separator: ", "))"
    
    let updateInfo = profile.needsUpdate ? "⚠️ Needs update" : "✅ Up to date"
    
    let genderInfo = profile.gender != .notSpecified ? profile.gender.displayName : "Not specified"
    
    info("""
    \(action) User Profile:
    📝 Name: \(profile.name)
    👶 Stage: \(profile.babyStage.displayName)
    🎂 Age: \(ageInfo)
    ⚧ Gender: \(genderInfo)
    ❤️ Interests: \(interestsInfo)
    🕐 Last Update: \(dateFormatter.string(from: profile.lastUpdate))
    📊 Status: \(updateInfo)
    """, category: .userProfile)
  }
  
  // MARK: - Private Methods
  private static func levelIcon(for level: Level) -> String {
    switch level {
    case .debug:
      return "🔍"
    case .info:
      return "ℹ️"
    case .warning:
      return "⚠️"
    case .error:
      return "❌"
    }
  }
}
