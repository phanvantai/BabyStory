//
//  FeedbackServiceProtocol.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 13/6/25.
//

import Foundation

/// Protocol defining the interface for feedback service
protocol FeedbackServiceProtocol {
    /// Submits feedback to the remote API
    /// - Parameter request: The feedback request to submit
    /// - Throws: AppError if the submission fails
    func submitFeedback(_ request: FeedbackRequest) async throws
}
