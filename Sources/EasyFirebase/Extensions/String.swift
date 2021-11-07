//
//  String.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation

extension String {
  
  // MARK: - Internal Methods
  
  internal func removeDomainFromEmail() -> String {
    var copy = String(self)
    if let range = copy.range(of: "@") {
      copy.removeSubrange(range.lowerBound ..< copy.endIndex)
    }
    return copy
  }
}
