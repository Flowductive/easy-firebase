//
//  Singleton.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation

public typealias SingletonName = DocumentID

/**
 A singleton is an object that belongs to a single Firestore collection, `singleton`, where only one object of this type is intended to exist.
 
 Singletons are useful for managing a collection of data from a single source.
 
 For instance, app authors may want to keep a `singleton` list of featured item `id`s that any user can access.
 */
public protocol Singleton: Document {
  
  /// The name of the singleton
  var id: SingletonName { get set }
}
