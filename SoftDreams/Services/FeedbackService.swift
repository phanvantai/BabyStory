//
//  FeedbackService.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 13/6/25.
//

import Foundation
import UIKit

/// Service responsible for submitting feedback to the remote API
class FeedbackService: FeedbackServiceProtocol {
    static let shared = FeedbackService()
    
    private let baseURL = "https://feedback.taiphanvan.dev/api/v1"
    private let session = URLSession.shared
    
    private init() {}
    
    /// Submits feedback to the remote API
    /// - Parameter request: The feedback request to submit
    /// - Throws: AppError if the submission fails
    func submitFeedback(_ request: FeedbackRequest) async throws {
        guard let url = URL(string: "\(baseURL)/support-request") else {
            Logger.error("Invalid feedback API URL", category: .network)
            throw AppError.networkError
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            Logger.info("Submitting feedback request", category: .network)
            
            let (_, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error("Invalid response type from feedback API", category: .network)
                throw AppError.networkError
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                Logger.error("Feedback API returned error status: \(httpResponse.statusCode)", category: .network)
                throw AppError.networkError
            }
            
            Logger.info("Feedback submitted successfully", category: .network)
            
        } catch let error as AppError {
            throw error
        } catch {
            Logger.error("Failed to submit feedback: \(error.localizedDescription)", category: .network)
            throw AppError.networkError
        }
    }
}

/// Extension to get device information for feedback
extension FeedbackService {
    /// Gets the current device model string
    static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown Device"
    }
    
    /// Gets the current app version
    static func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
