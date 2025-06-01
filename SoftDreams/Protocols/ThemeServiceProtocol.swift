import Foundation

// MARK: - Theme Service Protocol
/// Handles theme and appearance settings persistence
protocol ThemeServiceProtocol {
  /// Save the current theme mode
  /// - Parameter theme: The theme mode to save
  func saveTheme(_ theme: ThemeMode)
  
  /// Load the current theme mode
  /// - Returns: The saved theme mode, or default if none exists
  func loadTheme() -> ThemeMode
}
