//
//  Storage.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

public typealias FieldName = String

@available(iOS 13.0, *)
extension EasyFirestore {
  
  /**
   A service used for storing objects in Firestore.
   */
  public struct Storage {
    
    // MARK: - Public Static Methods
    
    /**
     Sets a document in Firestore.
     
     - parameter document: The document to set in Firestore.
     - parameter completion: The completion handler.
     */
    public static func set<T>(_ document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      set(document, collection: document.typeName, id: document.id, completion: completion)
    }
    
    /**
     Sets a singleton in Firestore.
     
     - parameter singleton: The singleton to set in Firestore.
     - parameter completion: The completion handler.
     */
    public static func set<T>(_ singleton: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Singleton {
      set(singleton, collection: "Singleton", id: singleton.id, completion: completion)
    }
    
    /**
     Updates a value for a particular field in Firestore.
     
     - parameter path: The path to the document's field to update.
     - parameter document: The document with the updated field.
     - parameter completion: The completion handler.
     */
    public static func set<T, U>(_ path: KeyPath<T, U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      let value = document[keyPath: path]
      db.collection(String(describing: T.self)).document(document.id).updateData([path.string: value], completion: completion)
    }
    
    /**
     Updates a value for a particular field in Firestore.
     
     - parameter value: The new value to update.
     - parameter path: the path to the document's field in Firestore.
     - parameter document: The document with the field to update.
     - parameter completion: The completion handler.
     */
    public static func set<T, U>(_ value: U, to path: KeyPath<T, U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      set(path, in: document, completion: completion)
    }
    
    /**
     Sets the object in Firestore, then assigns it to a parent document's field list of `DocumentID`s.
     
     - parameter document: The document to store in Fires
     - parameter child: The child document (only used to get an ID).
     - parameter path: The path of the parent document's field containing the list of `DocumentID`s.
     - parameter parent: The parent document containing the list of `DocumentID`s.
     - parameter completion: The completion handler.
     */
    public static func setAssign<T, U>(_ document: T, to path: KeyPath<U, [DocumentID]>, in parent: U, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Document {
      set(document) { error in
        if let error = error {
          completion(error)
          return
        }
        Linking.assign(document, to: path, in: parent, completion: completion)
      }
    }
    
    // MARK: - Private Static Methods
    
    private static func set<T>(_ model: T, collection: CollectionName, id: String, completion: @escaping (Error?) -> Void) where T: Model {
      do {
        _ = try db.collection(collection).document(id).setData(from: model) { error in
          if let error = error {
            EasyFirebase.log(error: error.localizedDescription)
          } else {
            EasyFirebase.log("Document successfully sent to [\(collection)] collection. ID: \(id)")
          }
          completion(error)
        }
      } catch {
        EasyFirebase.log(error: error)
      }
    }
  }
}
