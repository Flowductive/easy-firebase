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
    public static func set<T, U>(field: FieldName, using path: KeyPath<T, U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      let value = document[keyPath: path]
      let collectionName = String(describing: T.self)
      db.collection(collectionName).document(document.id).updateData([field: value], completion: completion)
    }
    
    /**
     Updates a value for a particular field in Firestore.
     
     - parameter value: The new value to update.
     - parameter path: the path to the document's field in Firestore.
     - parameter document: The document with the field to update.
     - parameter completion: The completion handler.
     */
    public static func set<T, U>(field: FieldName, with value: U, using path: KeyPath<T, U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      let collectionName = String(describing: T.self)
      db.collection(collectionName).document(document.id).updateData([field: value], completion: completion)
    }
    
    /**
     Sets the object in Firestore, then assigns it to a parent document's field list of `DocumentID`s.
     
     - parameter document: The document to store in Firestore.
     - parameter child: The child document (only used to get an ID).
     - parameter path: The path of the parent document's field containing the list of `DocumentID`s.
     - parameter parent: The parent document containing the list of `DocumentID`s.
     - parameter completion: The completion handler.
     */
    public static func setAssign<T, U>(_ document: T, toField field: FieldName, using path: KeyPath<U, [T.ID]>, in parent: U, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Document {
      set(document) { error in
        if let error = error {
          completion(error)
          return
        }
        Linking.assign(document, toField: field, using: path, in: parent, completion: completion)
      }
    }
    
    /**
     Sets a (default) document in Firestore only if the document does not exist.
     
     This method is used to create new documents in Firestore without being destructive. For instance, if user objects have other document types unique to them, you may want to create these new documents under the condition that they don't already exist (to prevent user data loss).
     
     - parameter document: The document to set in Firestore.
     - parameter id: The ID of the document to check in Firestore. If set to `nil`, the ID of the document being set will be used to check.
     */
    public static func setIfNone<T>(_ document: T, checking id: T.ID? = nil, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      var checkID = document.id
      if let id = id {
        checkID = id
      }
      db.collection(String(describing: T.self)).document(checkID).getDocument { result, error in
        guard error == nil else { return }
        guard let result = result else { return }
        guard !result.exists else { return }
        `set`(document, completion: completion)
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
