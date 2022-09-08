//
//  Updating.swift
//  
//
//  Created by Ben Myers on 3/10/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@available(iOS 13.0, *)
extension EasyFirestore {
  
  /**
   A service used for storing objects in Firestore.
   */
  public struct Updating {
    
    // MARK: - Public Static Methods
    
    /**
     Increments a value for a particular field in Firestore.
     
     - parameter path: The path to the document's field to update.
     - parameter increase: The amount to increase.
     - parameter document: The document with the updated field.
     - parameter completion: The completion handler.
     */
    public static func increment<T, U>(_ path: KeyPath<T, U>, by increase: Int = 1, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: AdditiveArithmetic {
      let collectionName = String(describing: type(of: document))
      db.collection(collectionName).document(document.id).updateData([path.string: FieldValue.increment(Int64(increase))], completion: completion)
    }
    
    /**
     Appends a value to an array in a field in Firestore.
     
     - parameter path: The path to the document's field to update.
     - parameter item: The new item to append.
     - parameter document: The document to modify.
     - parameter completion: The completion handler.
     */
    public static func append<T, U>(_ path: KeyPath<T, Array<U>>, with item: U, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      append(path, with: [item], in: document, completion: completion)
    }
    
    /**
     Appends a value to an array in a field in Firestore.
     
     - parameter path: The path to the document's field to update.
     - parameter items: The new items to append.
     - parameter document: The document to modify.
     - parameter completion: The completion handler.
     */
    public static func append<T, U>(_ path: KeyPath<T, Array<U>>, with items: Array<U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      let collectionName = String(describing: type(of: document))
      db.collection(collectionName).document(document.id).updateData([path.string: FieldValue.arrayUnion(items)], completion: completion)
    }
    
    /**
     Removes a value from an array in a field in Firestore.
     
     - parameter path: The path to the document's field to update.
     - parameter item: The item to remove.
     - parameter document: The document to modify.
     - parameter completion: The completion handler.
     */
    public static func remove<T, U>(_ path: KeyPath<T, Array<U>>, taking item: U, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      remove(path, taking: [item], in: document, completion: completion)
    }
    
    /**
     Appends a value to an array in a field in Firestore.
     
     - parameter path: The path to the document's field to update.
     - parameter items: The items to remove.
     - parameter document: The document to modify.
     - parameter completion: The completion handler.
     */
    public static func remove<T, U>(_ path: KeyPath<T, Array<U>>, taking items: Array<U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      let collectionName = String(describing: type(of: document))
      db.collection(collectionName).document(document.id).updateData([path.string: FieldValue.arrayRemove(items)], completion: completion)
    }
    
    /**
     Updates a key-value pair to a map in a field in Firestore.
     
     ℹ️ **Note:** This will not override and erase other key/value pairs in the same field.

     - parameter key: The key of the value to update in the map in a field in Firestore.
     - parameter value: The value to update in the map in a field in Firestore.
     - parameter path: The path to the document's map field to update.
     - parameter document: The document to modify.
     - parameter completion: The completion handler.
     */
    public static func updateMapValue<T, U>(key: String, value: U?, to path: KeyPath<T, Dictionary<String, U>>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      let collectionName = String(describing: type(of: document))
      let fullPath: String = "\(path.string).\(key)"
      db.collection(collectionName).document(document.id).updateData([fullPath: value as Any], completion: completion)
    }

    /**
     Updates key-value pairs to a map in a field in Firestore.
     
     ℹ️ **Note:** This will not override and erase other key/value pairs in the same field.

     - parameter pairs: The pairs to add to the map value.
     - parameter path: The path to the document's map field to update.
     - parameter document: The document to modify.
     - parameter completion: The completion handler.
     */
    public static func updateMapValues<T>(pairs dict: [String: Any], to path: KeyPath<T, Dictionary<String, Any>>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      let collectionName = String(describing: type(of: document))
      var data: [String: Any] = [:]
      for (mapKey, mapValue) in dict {
        let fullPath: String = "\(path.string).\(mapKey)"
        data[fullPath] = mapValue
      }
      db.collection(collectionName).document(document.id).updateData(data, completion: completion)
    }
    
    /**
     Removes a key-value pair from a map in a field in Firestore.

     - parameter key: The key of the value to remove in the map in a field in Firestore.
     - parameter path: The path to the document's map field to remove from.
     - parameter document: The document to modify.
     - parameter completion: The completion handler.
     */
    public static func removeMapValue<T, U>(key: String, from path: KeyPath<T, Dictionary<String, U>>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      updateMapValue(key: key, value: nil, to: path, in: document, completion: completion)
    }
  }
}
