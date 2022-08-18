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
    public static func increment<T, U>(_ path: KeyPath<T, U>, by increase: Int, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: AdditiveArithmetic {
      let collectionName = String(describing: T.self)
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
      let collectionName = String(describing: T.self)
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
      let collectionName = String(describing: T.self)
      db.collection(collectionName).document(document.id).updateData([path.string: FieldValue.arrayRemove(items)], completion: completion)
    }
  }
}
