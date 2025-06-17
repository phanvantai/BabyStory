//
//  FeedbackViewModel.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 13/6/25.
//

import Foundation

/// ViewModel managing feedback submission functionality
@MainActor
class FeedbackViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var message: String = ""
    @Published var userEmail: String = ""
    @Published var selectedType: FeedbackType = .feedback
    @Published var isSubmitting: Bool = false
    @Published var showSuccessMessage: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let feedbackService: FeedbackServiceProtocol
    
    // MARK: - Computed Properties
    var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(userEmail) &&
        !isSubmitting
    }
    
    // MARK: - Initialization
    init(feedbackService: FeedbackServiceProtocol = FeedbackService.shared) {
        self.feedbackService = feedbackService
    }
    
    // MARK: - Public Methods
    
    /// Submits the feedback to the API
    func submitFeedback() async {
        guard canSubmit else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let request = FeedbackRequest(
                app: "SoftDreams",
                appVersion: FeedbackService.getAppVersion(),
                deviceModel: FeedbackService.getDeviceModel(),
                message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                platform: "iOS",
                type: selectedType.rawValue,
                userEmail: userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            try await feedbackService.submitFeedback(request)
            
            // Success
            showSuccessMessage = true
            clearForm()
            
            Logger.info("Feedback submitted successfully", category: .general)
            
        } catch {
            Logger.error("Failed to submit feedback: \(error.localizedDescription)", category: .general)
            errorMessage = "feedback_error_submission".localized
        }
        
        isSubmitting = false
    }
    
    /// Clears the feedback form
    func clearForm() {
        message = ""
        userEmail = ""
        selectedType = .feedback
    }
    
    /// Dismisses the success message
    func dismissSuccessMessage() {
        showSuccessMessage = false
    }
    
    /// Clears the error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    /// Validates email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
