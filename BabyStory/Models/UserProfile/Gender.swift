//
//  Gender.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation

enum Gender: String, Codable, CaseIterable {
  case male = "male"
  case female = "female"
  case notSpecified = "not_specified"
  
  var displayName: String {
    switch self {
    case .male:
      return "Boy"
    case .female:
      return "Girl"
    case .notSpecified:
      return "Not Specified"
    }
  }
  
  var pronoun: String {
    switch self {
    case .male:
      return "he"
    case .female:
      return "she"
    case .notSpecified:
      return "they"
    }
  }
  
  var possessivePronoun: String {
    switch self {
    case .male:
      return "his"
    case .female:
      return "her"
    case .notSpecified:
      return "their"
    }
  }
}
