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

/*
extension Document {
  
  // MARK: - Static Methods

  /**
   Gets the document from Firestore.
   
   - parameter id: The ID of the document
   - parameter completion: The completion handler
   */
  static func get(_ id: DocumentID, completion: @escaping (Self?) -> Void) {
    FirestoreService.Retrieval.get(from: id, ofType: self) { document in
      completion(document)
    }
  }
  
  // MARK: - Methods
  
  /**
   Gets a field from Firestore.
   
   - parameter path: The path to the field
   - parameter completion: The completion handler
   */
  func get<T>(_ path: KeyPath<Self, T>, completion: @escaping (T?) -> Void) {
    Self.get(id, completion: { document in
      guard let document = document else {
        completion(nil)
        return
      }
      let value = document[keyPath: path]
      completion(value)
    })
  }
  
  /**
   Gets several fields at once from Firestore.
   
   These fields must have the same type.
   
   - parameter paths: The paths to the fields
   - parameter completion: The completion handler
   */
  func get<T>(_ paths: KeyPath<Self, T> ..., completion: @escaping ([T?]) -> Void) {
    var arr: [T?] = []
    Self.get(id, completion: { document in
      guard let document = document else {
        completion([])
        return
      }
      for path in paths {
        arr.append(document[keyPath: path])
      }
      completion(arr)
    })
  }
  
  /**
   Pushes the entire document to Firestore.
   
   - parameter completion: The completion handler
   */
  func push(completion: @escaping (Error?) -> Void = { _ in }) {
    _ = FirestoreService.Storage.set(self, completion: completion)
  }
  
  /**
   Pushes a specific field to Firestore.
   
   - parameter field: The key of the data
   - parameter path: The path to the local field
   - parameter completion: The completion handler
   */
  func push<T>(_ field: String, path: KeyPath<Self, T>, completion: @escaping () -> Void = {}) {
    self._push(field, value: self[keyPath: path], completion: completion)
  }
  
  /**
   Pushes specific fields to Firestore, all at once.
   
   This method saves on Firestore write counts by batching multiple single field updates into a single job.
   
   The key path value types for this method must be the same.
   
   - parameter pairs: The key-value pairs of data to push
   - parameter completion: The completion handler
   */
  func push<T>(_ pairs: (String, KeyPath<Self, T>)..., completion: @escaping () -> Void = {}) {
    var converted: [(String, Any)] = []
    for pair in pairs {
      converted.append((pair.0, self[keyPath: pair.1]))
    }
    self._push(converted, completion: completion)
  }
  
  /**
   Pushes specific fields to Firestore, all at once.
   
   This method saves on Firestore write counts by batching multiple single field updates into a single job.
   
   - parameter pair0: The first key-value pair of data to push
   - parameter pair1: The second key-value pair of data to push
   - parameter completion: The completion handler
   */
  func push<T0, T1>(_ pair0: (String, KeyPath<Self, T0>), _ pair1: (String, KeyPath<Self, T1>), completion: @escaping () -> Void = {}) {
    var converted: [(String, Any)] = []
    converted.append((pair0.0, self[keyPath: pair0.1]))
    converted.append((pair1.0, self[keyPath: pair1.1]))
    self._push(converted, completion: completion)
  }
  
  /**
   Pushes specific fields to Firestore, all at once.
   
   This method saves on Firestore write counts by batching multiple single field updates into a single job.
   
   - parameter pair0: The first key-value pair of data to push
   - parameter pair1: The second key-value pair of data to push
   - parameter pair2: The third key-value pair of data to push
   - parameter completion: The completion handler
   */
  func push<T0, T1, T2>(_ pair0: (String, KeyPath<Self, T0>), _ pair1: (String, KeyPath<Self, T1>), _ pair2: (String, KeyPath<Self, T2>), completion: @escaping () -> Void = {}) {
    var converted: [(String, Any)] = []
    converted.append((pair0.0, self[keyPath: pair0.1]))
    converted.append((pair1.0, self[keyPath: pair1.1]))
    converted.append((pair2.0, self[keyPath: pair2.1]))
    self._push(converted, completion: completion)
  }
  
  /**
   Pushes, first updating locally, specific data to Firestore.
   
   This allows local and remote pushing to be done in a single line of code.
   
   - parameter value: The new value to update with
   - parameter field: The key of the data
   - parameter path: The path to the local field
   - parameter completion: The completion handler
   */
  mutating func push<T>(value: T, to field: String, path: WritableKeyPath<Self, T>, completion: @escaping () -> Void = {}) {
    self[keyPath: path] = value
    self._push(field, value: self[keyPath: path], completion: completion)
  }
  
  // MARK: - Private Methods
  
  private func _push(_ field: String, value: Any, completion: @escaping () -> Void = {}) {
    _push([(field, value)], completion: completion)
  }
  
  private func _push(_ pairs: [(String, Any)], completion: @escaping () -> Void = {}) {
    if pairs.map({ $0.1 }).contains(where: {
      return ($0 is Model && !($0 is SafeModel)) || ($0 is [Model] && !($0 is [SafeModel]))
    }) {
      fatalError("You can't push Models as values directly to Firestore! Push the entire document instead.")
    }
    FirestoreService.Storage.update(FirestoreService.DocumentLookup(type: Self.self,
                                                                    id: id), with: pairs, completion: { _ in completion() })
  }
}

/**
 A protocol for documents that can be queried in terms of searching.
 
 All searchable documents must have an identifier to locate the document, regardless of query case, special characters, or spacing.
 
 Objects that conform to `QueryableDocument` have up to 5 queryable properties for query searching.
 */
protocol QueryableDocument: Document {
  
  /// The amount of queryables this document type has
  var queryables: Int { get }
}

extension QueryableDocument {
  
  // MARK: - Properties
  
  /// The first queryable for this document
  var q0: String? { get { nil }}
  /// The second queryable for this document
  var q1: String? { get { nil }}
  /// The third queryable for this document
  var q2: String? { get { nil }}
  /// The fourth queryable for this document
  var q3: String? { get { nil }}
  /// The fifth queryable for this document
  var q4: String? { get { nil }}
}
*/
