//
//  File.swift
//  
//
//  Created by Ben Myers on 10/31/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@available(iOS 13.0, *)
extension EasyFirestore {
  
  /**
   A service assisting with the removal and unassignment of documents in Firestore.
   */
  public struct Removal {
    
    // MARK: - Public Static Methods
    
    /**
     Removes a document from its collection in Firestore.
     
     If you have the document you'd like to remove as a local object, consider using ``remove(_:completion:)`` to simplify your code.
     
     - parameter id: The ID of the document to remove.
     - parameter type: The type of document to remove.
     - parameter completion: The completion handler.
     */
    public static func remove<T>(id: DocumentID, ofType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      let collectionName = String(describing: T.self)
      db.collection(collectionName).document(id).delete { error in
        completion(error)
      }
    }
    
    /**
     Removes a document from its collection in Firestore.
     
     If you don't have access to your document as a local object, consider using ``remove(id:ofType:completion:)``.
     
     - parameter document: The document to remove.
     - parameter completion: The completion handler.
     */
    public static func remove<T>(_ document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      remove(id: document.id, ofType: T.self, completion: completion)
    }
    
    /**
     Unassigns the document from a parent in Firestore, then removes the document from its collection in Firestore.
     
     - parameter document: The document to unassign and remove.
     - parameter path: The path of the parent document's field containing the list of `DocumentID`s.
     - parameter parent: The parent document containing the list of `DocumentID`s.
     - parameter completion: The completion handler.
     
     For more information on unassignment, check out `EasyFirestore.Linking`.
     */
    public static func removeUnassign<T, U>(_ document: T, fromField field: FieldName, using path: KeyPath<U, [DocumentID]>, in parent: U, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Document {
      Linking.unassign(document, fromField: field, using: path, in: parent, completion: { error in
        if let error = error {
          completion(error)
          return
        }
        remove(document, completion: completion)
      })
    }
  }
}
