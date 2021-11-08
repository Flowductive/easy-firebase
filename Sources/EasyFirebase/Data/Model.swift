//
//  Model.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation

public protocol Model: Codable {}

extension Model {
  
  // MARK: - Public Properties
  
  /// A string representing the model's type.
  public var typeName: CollectionName {
    return String(describing: self)
  }
}
