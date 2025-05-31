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
      return "gender_display_name_male".localized
    case .female:
      return "gender_display_name_female".localized
    case .notSpecified:
      return "gender_display_name_not_specified".localized
    }
  }
  
  var pronoun: String {
    switch self {
    case .male:
      return "gender_pronoun_male".localized
    case .female:
      return "gender_pronoun_female".localized
    case .notSpecified:
      return "gender_pronoun_not_specified".localized
    }
  }
  
  var possessivePronoun: String {
    switch self {
    case .male:
      return "gender_possessive_pronoun_male".localized
    case .female:
      return "gender_possessive_pronoun_female".localized
    case .notSpecified:
      return "gender_possessive_pronoun_not_specified".localized
    }
  }
}
