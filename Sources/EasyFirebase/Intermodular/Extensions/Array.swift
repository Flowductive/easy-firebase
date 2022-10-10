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
