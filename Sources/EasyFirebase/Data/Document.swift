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

extension Document {
  
  // MARK: - Public Methods
  
  public func set(completion: @escaping (Error?) -> Void = { _ in }) {
    EasyFirestore.Storage.set(self, completion: completion)
  }
  
  public func set<T>(_ path: KeyPath<Self, T>, completion: @escaping (Error?) -> Void = { _ in }) where T: Codable {
    EasyFirestore.Storage.set(self[keyPath: path], to: path.string, in: self)
  }
  
  public mutating func set<T>(_ value: T, to path: WritableKeyPath<Self, T>, completion: @escaping (Error?) -> Void = { _ in }) where T: Codable {
    self[keyPath: path] = value
    set(path, completion: completion)
  }
  
  public func get<T>(_ path: KeyPath<Self, T>, completion: @escaping (T?) -> Void) where T: Codable {
    EasyFirestore.Retrieval.get(id: id, ofType: Self.self) { document in
      guard let document = document else {
        completion(nil)
        return
      }
      completion(document[keyPath: path])
    }
  }
}
