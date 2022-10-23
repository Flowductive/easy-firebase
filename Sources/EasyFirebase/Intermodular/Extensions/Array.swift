//
//  File.swift
//  
//
//  Created by Ben Myers on 10/8/22.
//

import Foundation

extension Array {
  
  internal func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

extension Array where Element: Equatable {
  
  /**
   Appends an element to the array if it isn't in the array.
   
   - parameter newElement: The new element to add
   - parameter limit: The maxiumum amount of items the array can have
   */
  @inlinable mutating func appendUniquely(_ newElement: Element, limit: Int? = nil) {
    if !contains(newElement) {
      if let limit = limit {
        if count < limit {
          append(newElement)
        }
      } else {
        append(newElement)
      }
    }
  }
  
  /**
   Appends elements of an array to the array uniquely.
   
   - parameter newElements: The new elements to add
   - parameter condition: The condition to filter new unique elements with.
   */
  @inlinable mutating func appendUniquely<S>(
    contentsOf newElements: S,
    where condition: (S.Element) -> Bool = { _ in true }
  ) where Element == S.Element, S: Sequence {
    for element in newElements {
      if condition(element) {
        self.appendUniquely(element)
      }
    }
  }
  
  /**
   Inserts an element at the beginning of the array if it isn't in the array.
   
   - parameter newElement: The new element to insert
   - parameter limit: The maxiumum amount of items the array can have
   */
  @inlinable mutating func pushUniquely(_ newElement: Element, limit: Int? = nil) {
    if !contains(newElement) {
      insert(newElement, at: 0)
      if let limit = limit, count > limit {
        removeLast()
      }
    } else if let limit = limit {
      removeAll(of: newElement)
      insert(newElement, at: 0)
      while count > limit {
        removeLast()
      }
    }
  }
  
  /**
   Removes all instances of a provided element.
   
   - parameter match: The element to match
   */
  @inlinable mutating func removeAll(of match: Element) {
    self.removeAll(where: { $0 == match })
  }
  
  @inlinable mutating func removeAll(of matches: [Element]) {
    for element in matches {
      removeAll(of: element)
    }
  }
}
