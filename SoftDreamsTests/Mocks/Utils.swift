//
//  Utils.swift
//  SoftDreamsTests
//
//  Created by Tai Phan Van on 3/6/25.
//

import Foundation
@testable import SoftDreams

// MARK: - Mock UserProfile Extension
extension UserProfile {
    static var mockProfile: UserProfile {
        UserProfile(
            name: "Test Child",
            babyStage: .toddler,
            interests: ["Adventure", "Animals"],
            storyTime: Date(),
            language: .english
        )
    }
}
