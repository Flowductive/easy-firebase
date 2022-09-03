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
    
    public typealias ConditionBlock<T, V> = (KeyPath<T, V>, Condition<T, V>.Comparison, V)
    
    // MARK: - Public Static Methods
    
    /**
     Queries a collection of documents, matching the given string.
     
     - parameter path: The path to the field to check.
     - parameter order: The way the documents are ordered. This will always order by the field provided in the `path` parameter.
     - parameter limit: The maximum amount of documents to query.
     */
    public static func `where`<T>(_ path: KeyPath<T, String>,
                                  matches str: String,
                                  order: Order? = nil,
                                  limit: Int? = nil,
                                  completion: @escaping ([T]) -> Void
    ) where T: Document {
      `where`([Condition(path: path, comparison: .greaterEqualTo, value: str), Condition(path: path, comparison: .lessThan, value: str.incremented())],
              order: order,
              limit: limit,
              completion: completion
      )
    }
    
    /**
     Queries a collection of documents, matching the given condition.
     
     Use the `path` argument to specify the collection to query. For instance, if you have a collection of `MyUser` objects, and you want to search for users matching the `displayName` of `"Adam"`, you can query like so:
     
     ```
     EasyFirestore.Querying.where(\MyUser.displayName, .equals, "Adam") { users in
       // ...
     }
     ```
     
     - parameter path: The path to the field to check.
     - parameter comparison: The comparison to use.
     - parameter value: The value to compare with.
     - parameter order: The way the documents are ordered. This will always order by the field provided in the `path` parameter.
     - parameter limit: The maximum amount of documents to query.
     */
    public static func `where`<T, V>(_ path: KeyPath<T, V>,
                                  _ comparison: Condition<T, V>.Comparison,
                                  _ value: V,
                                  order: Order? = nil,
                                  limit: Int? = nil,
                                  completion: @escaping ([T]) -> Void
    ) where T: Document {
      `where`(Condition(path: path, comparison: comparison, value: value), order: order, limit: limit, completion: completion)
    }
    
    /**
     Queries a collection of documents, matching the given conditions.
     
     Each condition you wish to check is organized in `ConditionBlock`s. A `ConditionBlock` is equivalent to the tuple `(path, comparison, value)` of types `(KeyPath<_,_>, Comparison, Any)`. You can use this method to query with multiple conditions chained by the logical `AND` operator.
     
     ```
     EasyFirestore.Querying.where((\MyUser.displayName, .equals, "Adam"),
                                  (\MyUser.dateCreated, .lessThan, Date())
     ) { users in
       // ...
     }
     ```
     
     ⚠️ **Note:** If you are passing `order: .ascending` or `order: .descending` as an argument, ensure that your *first* `ConditionBlock` constrains the field you want to have ordered. In other words, if you are querying Condition 1 on field `displayName` and Condition 2 on field `dateCreated` (for instance), and if you pass `.ascending` to the `order` parameter, the results will be ordered by `displayName`, ascending.
     
     ```
     EasyFirestore.Querying.where((\MyUser.displayName, .equals, "Adam"),
                                  (\MyUser.dateCreated, .lessThan, Date()),
                                  order: .ascending,
                                  limit: 8
     ) { users in
       // Users will be ordered ascending by display name
     }
     ```
     
     - parameter path: The path to the field to check.
     - parameter comparison: The comparison to use.
     - parameter value: The value to compare with.
     - parameter order: The way the documents are ordered. See **Discussion** for more information.
     - parameter limit: The maximum amount of documents to query.
     */
    public static func `where`<T, V>(_ conditions: ConditionBlock<T, V> ...,
                                  order: Order? = nil,
                                  limit: Int? = nil,
                                  completion: @escaping ([T]) -> Void
    ) where T: Document {
      var conditionsArr: [Condition<T, V>] = []
      for condition in conditions {
        conditionsArr.append(Condition(path: condition.0, comparison: condition.1, value: condition.2))
      }
      `where`(conditionsArr, order: order, limit: limit, completion: completion)
    }
    
    // MARK: - Private Static Methods
    
    private static func `where`<T, V>(_ condition: Condition<T, V>, order: Order?, limit: Int?, completion: @escaping ([T]) -> Void) where T: Document {
      `where`([condition], order: order, limit: limit, completion: completion)
    }
    
    private static func `where`<T, V>(_ conditions: [Condition<T, V>], order: Order?, limit: Int?, completion: @escaping ([T]) -> Void) where T: Document {
      let collectionName = String(describing: T.self)
      let collection = db.collection(collectionName)
      guard conditions.count > 0 else { return }
      var query: Query = conditions.first!.apply(to: collection)
      for condition in conditions.dropFirst() {
        query = condition.apply(to: query)
      }
      if let order = order {
        if order == .ascending {
          query = query.order(by: conditions.first!.path.string)
        } else if order == .descending {
          query = query.order(by: conditions.first!.path.string, descending: true)
        }
      }
      if let limit = limit {
        query = query.limit(to: limit)
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
          }
          completion(arr)
        }
      })
    }
    
    // MARK: - Public Enumerations
    
    public enum Order {
      case ascending, descending
    }
    
    public struct Condition<T, V> {
      
      // MARK: - Public Properties
      
      /// The path of the field to query.
      public var path: KeyPath<T, V>
      /// The comparison used to filter a query.
      public var comparison: Comparison
      /// The value to check.
      public var value: V
      
      // MARK: - Internal Methods
      
      internal func apply(to reference: CollectionReference) -> Query {
        switch comparison {
        case .equals: return reference.whereField(path.string, isEqualTo: value)
        case .lessThan: return reference.whereField(path.string, isLessThan: value)
        case .lessEqualTo: return reference.whereField(path.string, isLessThanOrEqualTo: value)
        case .greaterThan: return reference.whereField(path.string, isGreaterThan: value)
        case .greaterEqualTo: return reference.whereField(path.string, isGreaterThanOrEqualTo: value)
        case .notEquals: return reference.whereField(path.string, isNotEqualTo: value)
        case .contains: return reference.whereField(path.string, arrayContains: value)
        case .in:
          guard let arr = value as? [Any] else {
            fatalError("You must pass an array as a value when using the IN query comparison.")
          }
          return reference.whereField(path.string, in: arr)
        case .notIn:
          guard let arr = value as? [Any] else {
            fatalError("You must pass an array as a value when using the NOT_IN query comparison.")
          }
          return reference.whereField(path.string, notIn: arr)
        case .containsAnyOf:
          guard let arr = value as? [Any] else {
            fatalError("You must pass an array as a value when using the CONTAINS_ANY_OF query comparison.")
          }
          return reference.whereField(path.string, arrayContainsAny: arr)
        }
      }
      
      internal func apply(to query: Query) -> Query {
        switch comparison {
        case .equals: return query.whereField(path.string, isEqualTo: value)
        case .lessThan: return query.whereField(path.string, isLessThan: value)
        case .lessEqualTo: return query.whereField(path.string, isLessThanOrEqualTo: value)
        case .greaterThan: return query.whereField(path.string, isGreaterThan: value)
        case .greaterEqualTo: return query.whereField(path.string, isGreaterThanOrEqualTo: value)
        case .notEquals: return query.whereField(path.string, isNotEqualTo: value)
        case .contains: return query.whereField(path.string, arrayContains: value)
        case .in:
          guard let arr = value as? [Any] else {
            fatalError("You must pass an array as a value when using the IN query comparison.")
          }
          return query.whereField(path.string, in: arr)
        case .notIn:
          guard let arr = value as? [Any] else {
            fatalError("You must pass an array as a value when using the NOT_IN query comparison.")
          }
          return query.whereField(path.string, notIn: arr)
        case .containsAnyOf:
          guard let arr = value as? [Any] else {
            fatalError("You must pass an array as a value when using the CONTAINS_ANY_OF query comparison.")
          }
          return query.whereField(path.string, arrayContainsAny: arr)
        }
      }
      
      // MARK: - Public Enumerations
      
      public enum Comparison {
        case equals, lessThan, greaterThan, lessEqualTo, greaterEqualTo, notEquals, contains, containsAnyOf, `in`, notIn
      }
    }
  }
}

#if canImport(CoreLocation)

import CoreLocation

@available(iOS 13.0, *)
public extension EasyFirestore.Querying {
  
  // MARK: - Static Methods
  
  /**
   Queries a collection of documents, grabbing documents that are near a provided location.
   
   - parameter path: The path to the field to check.
   - parameter order: The way the documents are ordered. This will always order by the field provided in the `path` parameter.
   - parameter limit: The maximum amount of documents to query.
   */
  static func near<T>(_ path: KeyPath<T, String>,
                      at location: CLLocationCoordinate2D,
                      precision: GeoPrecision = .normal,
                      order: Order? = nil,
                      limit: Int? = nil,
                      completion: @escaping ([T]) -> Void
  ) where T: GeoQueryable {
    let str: String = location.geohash(length: precision.rawValue)
    `where`(path, matches: str, order: order, limit: limit, completion: completion)
  }
}

private extension String {
  
}

#endif
