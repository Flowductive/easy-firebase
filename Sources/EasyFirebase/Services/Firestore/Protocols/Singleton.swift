//
//  Singleton.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation

/// The name of a singleton.
///
/// This applies as the singleton's unique identifier, as only one singleton should exist for its given name.
@available(*, deprecated, renamed: "Singleton.Name", message: "Use \"Singleton.Name\" o refrence a Singleton (string).")
public typealias SingletonName = DocumentID

/**
 A single-state object stored in Firestore containing centralized information.
 
 All singletons are stored in a collection named `singleton`. Each singleton should have it's own class, and only one singleton of each type should exist within the `singleton` collection.
 
 Singletons can be stored in Firestore using `EasyFirestore.Storage`.
 */
@available(iOS 13.0, *)
public protocol Singleton: Document {
  
  // MARK: - Type Aliases
  
  typealias Name = String
  
  // MARK: - Properties
  
  /// The name of the singleton.
  var id: Name { get set }
}
