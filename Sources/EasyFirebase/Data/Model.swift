//
//  File.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation

protocol Model: Codable {}

extension Model {
  
  // MARK: - Public Properties
  
  /// Gets a string representing the type of model.
  public var typeName: String {
    return String(describing: self)
  }
}
