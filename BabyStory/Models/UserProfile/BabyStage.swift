//
//  BabyStage.swift
//  BabyStory
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
        return "Create bonding stories for your unborn baby"
      case .newborn:
        return "Gentle, soothing stories for newborns"
      case .infant:
        return "Simple stories with sounds and textures"
      case .toddler:
        return "Interactive stories with basic lessons"
      case .preschooler:
        return "Adventure stories with moral lessons"
    }
  }
}
