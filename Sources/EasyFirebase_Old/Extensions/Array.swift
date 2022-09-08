//
//  Array.swift
//  
//
//  Created by Ben Myers on 11/7/21.
//

import Foundation

infix operator <=: AssignmentPrecedence
infix operator -=: AssignmentPrecedence

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
  
  // MARK: - Internal Methods
  
  internal func chunk(size: Int) -> [Self] {
    var arr = self
    var chunks = [Self]()
    while arr.count > 0 {
      var chunk: Self = []
      while arr.count > 0 && chunk.count < 10 {
        chunk.append(arr[0])
        arr.remove(at: 0)
      }
      chunks.append(chunk)
    }
    if chunks.count == 0 {
      chunks = [[]]
    }
    return chunks
  }
}
