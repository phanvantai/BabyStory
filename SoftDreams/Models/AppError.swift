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
  case invalidData
  case dailyStoryLimitReached
  case invalidConfiguration
  
  // Enhanced validation errors
  case invalidName
  case invalidDate
  case invalidStoryOptions
  case invalidCharacterCount
  case profileIncomplete
  
  // Network and feedback errors
  case networkError
  case feedbackSubmissionFailed
  case invalidFeedbackData
  
  var errorDescription: String? {
    switch self {
    case .storyGenerationFailed:
      return "app_error_story_generation_failed".localized
    case .profileSaveFailed:
      return "app_error_profile_save_failed".localized
    case .storySaveFailed:
      return "app_error_story_save_failed".localized
    case .invalidProfile:
      return "app_error_invalid_profile".localized
    case .networkUnavailable:
      return "app_error_network_unavailable".localized
    case .dataCorruption:
      return "app_error_data_corruption".localized
    case .dataSaveFailed:
      return "app_error_data_save_failed".localized
    case .dataExportFailed:
      return "app_error_data_export_failed".localized
    case .dataImportFailed:
      return "app_error_data_import_failed".localized
    case .invalidData:
      return "app_error_invalid_data".localized
    case .dailyStoryLimitReached:
      return "app_error_daily_story_limit_reached".localized
    case .invalidConfiguration:
      return "app_error_invalid_configuration".localized
    case .invalidName:
      return "app_error_invalid_name".localized
    case .invalidDate:
      return "app_error_invalid_date".localized
    case .invalidStoryOptions:
      return "app_error_invalid_story_options".localized
    case .invalidCharacterCount:
      return "app_error_invalid_character_count".localized
    case .profileIncomplete:
      return "app_error_profile_incomplete".localized
    case .networkError:
      return "app_error_network_error".localized
    case .feedbackSubmissionFailed:
      return "app_error_feedback_submission_failed".localized
    case .invalidFeedbackData:
      return "app_error_invalid_feedback_data".localized
    }
  }
  
  var recoverySuggestion: String? {
    switch self {
    case .storyGenerationFailed:
      return "app_error_recovery_story_generation".localized
    case .profileSaveFailed, .storySaveFailed, .dataSaveFailed:
      return "app_error_recovery_save_retry".localized
    case .invalidProfile, .profileIncomplete:
      return "app_error_recovery_profile_complete".localized
    case .networkUnavailable:
      return "app_error_recovery_network".localized
    case .dataCorruption:
      return "app_error_recovery_data_corruption".localized
    case .dataExportFailed:
      return "app_error_recovery_storage_space".localized
    case .dataImportFailed:
      return "app_error_recovery_file_corruption".localized
    case .invalidData:
      return "app_error_recovery_data_validation".localized
    case .dailyStoryLimitReached:
      return "app_error_recovery_upgrade_subscription".localized
    case .invalidConfiguration:
      return "app_error_recovery_configuration".localized
    case .invalidName:
      return "app_error_recovery_name_length".localized
    case .invalidDate:
      return "app_error_recovery_date_validation".localized
    case .invalidStoryOptions:
      return "app_error_recovery_story_options".localized
    case .invalidCharacterCount:
      return "app_error_recovery_character_limit".localized
    case .networkError:
      return "app_error_recovery_network_check".localized
    case .feedbackSubmissionFailed:
      return "app_error_recovery_feedback_retry".localized
    case .invalidFeedbackData:
      return "app_error_recovery_feedback_validation".localized
    }
  }
}

// MARK: - Error Manager
@MainActor
class ErrorManager: ObservableObject {
  @Published var currentError: AppError?
  @Published var showError = false
  
  func handleError(_ error: AppError) {
    currentError = error
    showError = true
  }
  
  func clearError() {
    currentError = nil
    showError = false
  }
}
