//
//  Model.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation

/**
 A protocol requiring `Codable` capabilities.
 
 Models can be sent as field values to documents in Firestore.
 */
public protocol Model: Codable {}

extension Model {
  
  // MARK: - Public Properties
  
  /// A string representing the model's type.
  public var typeName: CollectionName {
    return EasyFirestore.colName(of: Self.self)
  }
}
