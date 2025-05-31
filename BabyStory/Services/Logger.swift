import Foundation
import os.log

// MARK: - Logger
/// Simple logging utility for debugging and monitoring app behavior
struct Logger {
  
  // MARK: - Log Categories
  enum Category: String {
    case userProfile = "UserProfile"
    case autoUpdate = "AutoUpdate"
    case storage = "Storage"
    case storyGeneration = "StoryGeneration"
    case onboarding = "Onboarding"
    case settings = "Settings"
    case general = "General"
    case notification = "Notification"
    
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
      if let ageDisplay = profile.ageDisplayString {
        ageInfo = ageDisplay
      } else {
        ageInfo = "\(age) months"
      }
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
    language: \(profile.language.displayName)
    """, category: .userProfile)
  }
  
  // MARK: - Auto-Update Specific Logging
  static func logAutoUpdateCheck(_ profile: UserProfile) {
    let needsStageUpdate = profile.hasGrownToNewStage()
    let needsRegularUpdate = profile.needsUpdate
    let daysSinceUpdate = profile.daysSinceLastUpdate
    
    let stageInfo = needsStageUpdate ? 
      "🚀 Stage change detected: \(profile.babyStage.displayName) → \(profile.currentBabyStage.displayName)" : 
      "✅ Stage current: \(profile.babyStage.displayName)"
    
    let updateInfo = needsRegularUpdate ? 
      "⏰ Regular update needed (\(daysSinceUpdate) days since last update)" : 
      "✅ Recently updated (\(daysSinceUpdate) days ago)"
    
    info("""
    Auto-Update Check for \(profile.name):
    \(stageInfo)
    \(updateInfo)
    🔄 Requires update: \(needsStageUpdate || needsRegularUpdate ? "YES" : "NO")
    """, category: .autoUpdate)
  }
  
  static func logAutoUpdatePerformed(from oldProfile: UserProfile, to newProfile: UserProfile) {
    let stageChanged = oldProfile.babyStage != newProfile.babyStage
    let interestsChanged = oldProfile.interests != newProfile.interests
    
    var changes: [String] = []
    
    if stageChanged {
      changes.append("Stage: \(oldProfile.babyStage.displayName) → \(newProfile.babyStage.displayName)")
    }
    
    if interestsChanged {
      let oldInterests = Set(oldProfile.interests)
      let newInterests = Set(newProfile.interests)
      let added = newInterests.subtracting(oldInterests)
      let removed = oldInterests.subtracting(newInterests)
      
      if !added.isEmpty {
        changes.append("Added interests: \(added.joined(separator: ", "))")
      }
      if !removed.isEmpty {
        changes.append("Removed interests: \(removed.joined(separator: ", "))")
      }
    }
    
    let changesText = changes.isEmpty ? "No changes made" : changes.joined(separator: "\n")
    
    info("""
    🎉 Auto-Update Performed for \(newProfile.name):
    \(changesText)
    📅 Updated: \(dateFormatter.string(from: newProfile.lastUpdate))
    """, category: .autoUpdate)
  }
  
  static func logAutoUpdateSkipped(_ profile: UserProfile, reason: String) {
    info("⏭️ Auto-Update Skipped for \(profile.name): \(reason)", category: .autoUpdate)
  }
  
  static func logGrowthCelebration(_ profile: UserProfile) {
    if let growthMessage = profile.getGrowthMessage() {
      info("🎊 Growth Celebration: \(growthMessage)", category: .autoUpdate)
    }
  }
  
  static func logAutoUpdateError(_ e: Error, for profile: UserProfile) {
    error("❌ Auto-Update Failed for \(profile.name): \(e.localizedDescription)", category: .autoUpdate)
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
