//
//  String.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation

internal extension String {
  
  // MARK: - Internal Methods
  
  func removeDomainFromEmail() -> String {
    var copy = String(self)
    if let range = copy.range(of: "@") {
      copy.removeSubrange(range.lowerBound ..< copy.endIndex)
    }
    return copy
  }
}
