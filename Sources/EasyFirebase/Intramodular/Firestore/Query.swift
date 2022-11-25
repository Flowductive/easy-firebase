//
//  Query.swift
//  
//
//  Created by Ben Myers on 11/24/22.
//

import Foundation
import Firebase
import FirebaseFirestore

public struct Query<T> where T: Document {
  
  private var location: Document.Location
  private var blocks: [Block] = []
  private var order: Order?
  private var limit: Int?
  
  internal init(_ location: Document.Location) {
    self.location = location
  }
  
  private init(_ query: Query<T>, and newBlock: Block) {
    self.blocks = query.blocks
    self.blocks.append(newBlock)
    self.location = query.location
  }
  
  private init(_ query: Query<T>, order: Order) {
    self.blocks = query.blocks
    self.order = order
    self.location = query.location
  }
  
  private init(_ query: Query<T>, limit: Int) {
    self.blocks = query.blocks
    self.limit = limit
    self.location = query.location
  }
  
  private struct Block {
    var path: PartialKeyPath<T>
    var comparison: Comparison
    var value: Any
    
    internal func apply(to reference: FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query? {
      guard let key: String = (T()[keyPath: path] as! AnyField<FieldObject>).key else { return nil }
      switch comparison {
      case .equals: return reference.whereField(key, isEqualTo: value)
      case .lessThan: return reference.whereField(key, isLessThan: value)
      case .lessOrEqualTo: return reference.whereField(key, isLessThanOrEqualTo: value)
      case .greaterThan: return reference.whereField(key, isGreaterThan: value)
      case .greaterOrEqualTo: return reference.whereField(key, isGreaterThanOrEqualTo: value)
      case .notEquals: return reference.whereField(key, isNotEqualTo: value)
      case .contains: return reference.whereField(key, arrayContains: value)
      case .in:
        guard let arr = value as? [Any] else {
          fatalError("You must pass an array as a value when using the IN query comparison.")
        }
        return reference.whereField(key, in: arr)
      case .notIn:
        guard let arr = value as? [Any] else {
          fatalError("You must pass an array as a value when using the NOT_IN query comparison.")
        }
        return reference.whereField(key, notIn: arr)
      case .containsAnyOf:
        guard let arr = value as? [Any] else {
          fatalError("You must pass an array as a value when using the CONTAINS_ANY_OF query comparison.")
        }
        return reference.whereField(key, arrayContainsAny: arr)
      }
    }
    
    internal func apply(to query: FirebaseFirestore.Query) -> FirebaseFirestore.Query? {
      guard let key: String = (T()[keyPath: path] as? AnyField<T>)?.key else { return nil }
      switch comparison {
      case .equals: return query.whereField(key, isEqualTo: value)
      case .lessThan: return query.whereField(key, isLessThan: value)
      case .lessOrEqualTo: return query.whereField(key, isLessThanOrEqualTo: value)
      case .greaterThan: return query.whereField(key, isGreaterThan: value)
      case .greaterOrEqualTo: return query.whereField(key, isGreaterThanOrEqualTo: value)
      case .notEquals: return query.whereField(key, isNotEqualTo: value)
      case .contains: return query.whereField(key, arrayContains: value)
      case .in:
        guard let arr = value as? [Any] else {
          fatalError("You must pass an array as a value when using the IN query comparison.")
        }
        return query.whereField(key, in: arr)
      case .notIn:
        guard let arr = value as? [Any] else {
          fatalError("You must pass an array as a value when using the NOT_IN query comparison.")
        }
        return query.whereField(key, notIn: arr)
      case .containsAnyOf:
        guard let arr = value as? [Any] else {
          fatalError("You must pass an array as a value when using the CONTAINS_ANY_OF query comparison.")
        }
        return query.whereField(key, arrayContainsAny: arr)
      }
    }
  }
  
  private struct Order {
    var path: PartialKeyPath<T>
    var descending: Bool = false
  }
  
  public enum Comparison {
    case equals, lessThan, lessOrEqualTo, greaterThan, greaterOrEqualTo, notEquals, contains, containsAnyOf, `in`, notIn
  }
  
  private var firebaseQuery: FirebaseFirestore.Query? {
    let reference = location.reference
    guard blocks.count > 0 else { return nil }
    guard var query: FirebaseFirestore.Query = blocks.first!.apply(to: reference) else { return nil }
    for block in blocks.dropFirst(1) {
      if let q = block.apply(to: query) {
        query = q
      }
    }
    if let order, let key: String = (T()[keyPath: order.path] as? AnyField<T>)?.key {
      query.order(by: key, descending: order.descending)
    }
    if let limit {
      query.limit(to: limit)
    }
    return query
  }
}

// MARK: - Public Interface

extension Query {
  
  public func `where`(_ path: PartialKeyPath<T>, _ comparison: Comparison, _ value: Any) -> Query<T> {
    return Query(self, and: Block(path: path, comparison: comparison, value: value))
  }
  
  public func order(by path: PartialKeyPath<T>, descending: Bool = false) -> Query<T> {
    return Query(self, order: Order(path: path, descending: descending))
  }
  
  public func limit(to count: Int) -> Query<T> {
    return Query(self, limit: count)
  }
  
  public func execute(completion: @escaping (Result<Array<T>, Firestore.Error>) -> Void) {
    guard let query = firebaseQuery else {
      completion(.failure(.invalidQuery))
      return
    }
    query.getDocuments { snapshot, error in
      Document.handleQuerySnapshot(T.self, snapshot, error, from: location, handler: completion)
    }
  }
}
