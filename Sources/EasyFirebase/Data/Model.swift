//
//  Model.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation

public protocol Model: Codable {}

/**
 Models are objects that can be sent to and received from Firestore.
 
 Models can be documents belonging to a Firestore collection, and they can also be objects belonging to a document's field.
 */
extension Model {
  
  // MARK: - Public Properties
  
  /// A string representing the model's type
  public var typeName: CollectionName {
    return String(describing: self)
  }
}
