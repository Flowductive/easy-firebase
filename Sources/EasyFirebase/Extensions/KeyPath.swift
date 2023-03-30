//
//  KeyPath.swift
//  
//
//  Created by Ben Myers on 11/7/21.
//

import Foundation

extension KeyPath {
  
  // MARK: - Internal Properties
  
  internal var string: String {
    return NSExpression(forKeyPath: self).keyPath
  }
}
