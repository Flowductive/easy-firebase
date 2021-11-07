//
//  Array.swift
//  
//
//  Created by Ben Myers on 11/7/21.
//

import Foundation

infix operator <=
infix operator -=

extension Array where Element: Equatable {
  
  // MARK: - Internal Static Methods
  
  internal static func <= (lhs: inout Self, rhs: Element) {
    if !lhs.contains(rhs) {
      lhs.append(rhs)
    }
  }
  
  internal static func <= (lhs: inout Self, rhs: [Element]) {
    for item in rhs {
      lhs <= item
    }
  }
  
  internal static func -= (lhs: inout Self, rhs: Element) {
    lhs -= [rhs]
  }
  
  internal static func -= (lhs: inout Self, rhs: [Element]) {
    lhs.removeAll{ rhs.contains($0) }
  }
}
