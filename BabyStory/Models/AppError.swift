import Foundation

// MARK: - App Error Types
enum AppError: LocalizedError, Equatable {
  case storyGenerationFailed
  case profileSaveFailed
  case storySaveFailed
  case invalidProfile
  case networkUnavailable
  case dataCorruption
  case dataSaveFailed
  case dataExportFailed
  case dataImportFailed
  
  var errorDescription: String? {
    switch self {
    case .storyGenerationFailed:
      return "Unable to generate story. Please try again."
    case .profileSaveFailed:
      return "Failed to save profile changes."
    case .storySaveFailed:
      return "Failed to save story to library."
    case .invalidProfile:
      return "Profile information is incomplete or invalid."
    case .networkUnavailable:
      return "Network connection unavailable."
    case .dataCorruption:
      return "Data appears to be corrupted. Please restart the app."
    case .dataSaveFailed:
      return "Failed to save data. Please try again."
    case .dataExportFailed:
      return "Failed to export data. Please try again."
    case .dataImportFailed:
      return "Failed to import data. Please check the file and try again."
    }
  }
  
  var recoverySuggestion: String? {
    switch self {
    case .storyGenerationFailed:
      return "Check your internet connection and try generating the story again."
    case .profileSaveFailed, .storySaveFailed, .dataSaveFailed:
      return "Please try saving again. If the problem persists, restart the app."
    case .invalidProfile:
      return "Please complete all required profile fields."
    case .networkUnavailable:
      return "Connect to the internet and try again."
    case .dataCorruption:
      return "Restart the app. If the problem persists, you may need to reset your profile."
    case .dataExportFailed:
      return "Make sure you have enough storage space and try again."
    case .dataImportFailed:
      return "Ensure the file is not corrupted and was exported from BabyStory."
    }
  }
}

// MARK: - Error Manager
class ErrorManager: ObservableObject {
  @Published var currentError: AppError?
  @Published var showError = false
  
  func handleError(_ error: AppError) {
    DispatchQueue.main.async {
      self.currentError = error
      self.showError = true
    }
  }
  
  func clearError() {
    currentError = nil
    showError = false
  }
}
