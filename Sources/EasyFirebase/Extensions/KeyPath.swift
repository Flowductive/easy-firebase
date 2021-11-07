//
//  KeyPath.swift
//  
//
//  Created by Ben Myers on 11/7/21.
//

import Foundation

extension KeyPath {
  
  // MARK: - Internal Properties
  
  var stringValue: String {
    NSExpression(forKeyPath: self).keyPath
  }
}
