//
//  FeedbackRequest.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 13/6/25.
//

import Foundation

/// Model representing a feedback request to be sent to the feedback API
struct FeedbackRequest: Codable {
    let app: String
    let appVersion: String
    let deviceModel: String
    let message: String
    let platform: String
    let type: String
    let userEmail: String
    
    enum CodingKeys: String, CodingKey {
        case app
        case appVersion = "app_version"
        case deviceModel = "device_model"
        case message
        case platform
        case type
        case userEmail = "user_email"
    }
}

/// Types of feedback that can be submitted
enum FeedbackType: String, CaseIterable {
    case support = "support"
    case feedback = "feedback"
    case bugReport = "bug_report"
    case featureRequest = "feature_request"
    
    var displayName: String {
        switch self {
        case .support:
            return "feedback_type_support".localized
        case .feedback:
            return "feedback_type_general".localized
        case .bugReport:
            return "feedback_type_bug".localized
        case .featureRequest:
            return "feedback_type_feature".localized
        }
    }
    
    var icon: String {
        switch self {
        case .support:
            return "questionmark.circle.fill"
        case .feedback:
            return "bubble.left.and.bubble.right.fill"
        case .bugReport:
            return "ant.fill"
        case .featureRequest:
            return "lightbulb.fill"
        }
    }
}
