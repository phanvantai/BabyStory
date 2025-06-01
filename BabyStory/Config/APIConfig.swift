//
//  APIConfig.swift
//  BabyStory
//
//  Created by Tai Phan Van on 1/6/25.
//

import Foundation

enum APIConfig {
    static var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("Missing API Key")
        }
        return key
    }

    static let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? "https://api.openai.com/v1"
}
