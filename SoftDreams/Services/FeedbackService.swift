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
        
        guard let machineString = modelCode else { return "Unknown Device" }
        
        // Map machine identifier to readable device name
        return mapMachineIdentifierToDeviceName(machineString)
    }
    
    /// Maps machine identifier to human-readable device name
    private static func mapMachineIdentifierToDeviceName(_ machineString: String) -> String {
        switch machineString {
        // iPhone models
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE (1st generation)"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,2": return "iPhone 13 mini"
        case "iPhone14,3": return "iPhone 13"
        case "iPhone14,4": return "iPhone 13 Pro"
        case "iPhone14,5": return "iPhone 13 Pro Max"
        case "iPhone14,6": return "iPhone SE (3rd generation)"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        case "iPhone17,3": return "iPhone 16"
        case "iPhone17,4": return "iPhone 16 Plus"
        
        // iPad models
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad (3rd generation)"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad (4th generation)"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad6,11", "iPad6,12": return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6": return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12": return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7": return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2": return "iPad (9th generation)"
        case "iPad13,18", "iPad13,19": return "iPad (10th generation)"
        
        // iPad Air models
        case "iPad11,3", "iPad11,4": return "iPad Air (3rd generation)"
        case "iPad13,1", "iPad13,2": return "iPad Air (4th generation)"
        case "iPad13,16", "iPad13,17": return "iPad Air (5th generation)"
        case "iPad14,8", "iPad14,9": return "iPad Air (6th generation)"
        
        // iPad Pro models
        case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8": return "iPad Pro (12.9-inch)"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,9", "iPad8,10": return "iPad Pro (11-inch) (2nd generation)"
        case "iPad8,11", "iPad8,12": return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad14,3", "iPad14,4": return "iPad Pro (11-inch) (4th generation)"
        case "iPad14,5", "iPad14,6": return "iPad Pro (12.9-inch) (6th generation)"
        case "iPad16,3", "iPad16,4": return "iPad Pro (11-inch) (5th generation)"
        case "iPad16,5", "iPad16,6": return "iPad Pro (12.9-inch) (7th generation)"
        
        // iPad mini models
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad mini 3"
        case "iPad5,1", "iPad5,2": return "iPad mini 4"
        case "iPad11,1", "iPad11,2": return "iPad mini (5th generation)"
        case "iPad14,1", "iPad14,2": return "iPad mini (6th generation)"
        case "iPad16,1", "iPad16,2": return "iPad mini (7th generation)"
        
        // Simulator cases
        case "i386", "x86_64": return "Simulator"
        case "arm64":
            // For arm64, try to get more specific info
            if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
                return "Simulator"
            }
            return "Unknown ARM Device"
        
        default:
            return machineString
        }
    }
    
    /// Gets the current app version
    static func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
