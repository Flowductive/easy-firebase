//
//  Querying.swift
//  
//
//  Created by Ben Myers on 1/20/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@available(iOS 13.0, *)
extension EasyFirestore {
  
  /**
   A service for querying Firestore data.
   */
  public struct Querying {
    
    // MARK: - Public Static Methods
    
    public static func `where`<T>(_ path: KeyPath<T, Any>, _ comparison: Condition<T>.Comparison, _ value: Any, completion: @escaping ([T]) -> Void) where T: Document {
      `where`(Condition(path: path, comparison: comparison, value: value), completion: completion)
    }
    
    public static func `where`<T>(_ conditions: (KeyPath<T, Any>, Condition<T>.Comparison, Any) ..., completion: @escaping ([T]) -> Void) where T: Document {
      var conditionsArr: [Condition<T>] = []
      for condition in conditions {
        conditionsArr.append(Condition(path: condition.0, comparison: condition.1, value: condition.2))
      }
      `where`(conditionsArr, completion: completion)
    }
    
    // MARK: - Private Static Methods
    
    private static func `where`<T>(_ condition: Condition<T>, completion: @escaping ([T]) -> Void) where T: Document {
      `where`(condition, completion: completion)
    }
    
    private static func `where`<T>(_ conditions: [Condition<T>], completion: @escaping ([T]) -> Void) where T: Document {
      let collection = db.collection(String(describing: T.self))
      guard conditions.count > 0 else { return }
      var query: Query = conditions.first!.apply(to: collection)
      for condition in conditions.dropFirst() {
        query = condition.apply(to: query)
      }
      query.getDocuments(completion: { snapshot, error in
        if let error = error {
          EasyFirebase.log(error: error)
          completion([])
        } else if let snapshot = snapshot {
          var arr: [T] = []
          for document in snapshot.documents {
            let object = try? document.data(as: T.self)
            if let object = object {
              arr.append(object)
            }
            completion(arr)
          }
        }
      })
    }
    
    public struct Condition<T> {
      
      // MARK: - Public Properties
      
      /// The path of the field to query.
      public var path: KeyPath<T, Any>
      /// The comparison used to filter a query.
      public var comparison: Comparison
      /// The value to check.
      public var value: Any
      
      // MARK: - Internal Methods
      
      internal func apply(to reference: CollectionReference) -> Query {
        switch comparison {
        case .equals: return reference.whereField(path.string, isEqualTo: value)
        }
      }
      
      internal func apply(to query: Query) -> Query {
        switch comparison {
        case .equals: return query.whereField(path.string, isEqualTo: value)
        }
      }
      
      // MARK: - Public Enumerations
      
      public enum Comparison {
        case equals
      }
    }
  }
}
