//
//  BabyStage.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation

enum BabyStage: String, Codable, CaseIterable {
  case pregnancy = "pregnancy"
  case newborn = "newborn"
  case infant = "infant"
  case toddler = "toddler"
  case preschooler = "preschooler"
  
  var displayName: String {
    switch self {
    case .pregnancy:
      return "baby_stage_name_pregnancy".localized
    case .newborn:
      return "baby_stage_name_newborn".localized
    case .infant:
      return "baby_stage_name_infant".localized
    case .toddler:
      return "baby_stage_name_toddler".localized
    case .preschooler:
      return "baby_stage_name_preschooler".localized
    }
  }
  
  var description: String {
    switch self {
    case .pregnancy:
      return "baby_stage_description_pregnancy".localized
    case .newborn:
      return "baby_stage_description_newborn".localized
    case .infant:
      return "baby_stage_description_infant".localized
    case .toddler:
      return "baby_stage_description_toddler".localized
    case .preschooler:
      return "baby_stage_description_preschooler".localized
    }
  }
  
  /// Returns age-appropriate interests for this baby stage
  var availableInterests: [String] {
    switch self {
    case .pregnancy:
      return [
        "baby_stage_interest_classical_music".localized,
        "baby_stage_interest_nature_sounds".localized,
        "baby_stage_interest_gentle_stories".localized,
        "baby_stage_interest_parent_bonding".localized,
        "baby_stage_interest_relaxation".localized,
        "baby_stage_interest_love_care".localized
      ]
    case .newborn:
      return [
        "baby_stage_interest_lullabies".localized,
        "baby_stage_interest_gentle_sounds".localized,
        "baby_stage_interest_soft_colors".localized,
        "baby_stage_interest_comfort".localized,
        "baby_stage_interest_sleep".localized,
        "baby_stage_interest_feeding_time".localized,
        "baby_stage_interest_parent_voice".localized
      ]
    case .infant:
      return [
        "baby_stage_interest_peek_a_boo".localized,
        "baby_stage_interest_simple_sounds".localized,
        "baby_stage_interest_textures".localized,
        "baby_stage_interest_movement".localized,
        "baby_stage_interest_smiles".localized,
        "baby_stage_interest_discovery".localized,
        "baby_stage_interest_clapping".localized,
        "baby_stage_interest_faces".localized
      ]
    case .toddler:
      return [
        "baby_stage_interest_animals".localized,
        "baby_stage_interest_colors".localized,
        "baby_stage_interest_numbers".localized,
        "baby_stage_interest_vehicles".localized,
        "baby_stage_interest_nature".localized,
        "baby_stage_interest_family".localized,
        "baby_stage_interest_friends".localized,
        "baby_stage_interest_playing".localized,
        "baby_stage_interest_songs".localized,
        "baby_stage_interest_repetition".localized
      ]
    case .preschooler:
      return [
        "baby_stage_interest_adventure".localized,
        "baby_stage_interest_magic".localized,
        "baby_stage_interest_friendship".localized,
        "baby_stage_interest_learning".localized,
        "baby_stage_interest_imagination".localized,
        "baby_stage_interest_problem_solving".localized,
        "baby_stage_interest_emotions".localized,
        "baby_stage_interest_school".localized,
        "baby_stage_interest_helping_others".localized,
        "baby_stage_interest_curiosity".localized
      ]
    }
  }
}
