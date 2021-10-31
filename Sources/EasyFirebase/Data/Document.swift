//
//  Document.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation

public typealias DocumentID = String

/**
 A protocol for objects that can be sent to and received from Firebase Firestore.
 
 Classes or structs that conform to `Document` can easily be sent to Firestore using the universal `push(completion:)` method.
 
 Additionally, a static `push()` method also allows for certain key/values to only be pushed.
 */
public protocol Document: Model, Equatable, Identifiable {
  
  // MARK: - Properties
  
  /// The unique identifier of the model
  var id: String { get set }
  
  /// The date when the model was created
  var dateCreated: Date { get }
}
