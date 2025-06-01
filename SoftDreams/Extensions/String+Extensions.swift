//
//  String+Extensions.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 30/5/25.
//

import Foundation

extension String {
  var localized: String {
    NSLocalizedString(self, comment: "")
  }
}
