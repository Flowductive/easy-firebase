//
//  IndexedDocument.swift
//  
//
//  Created by Ben Myers on 1/20/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

/**
 A document that is indexed using a counter.
 
 Each new document that is created and pushed to Firestore has a unique index determined by an associated `Singleton` that is automatically created when the indexed document is created.
 */
public protocol IndexedDocument: Document {
  
  // MARK: - Public Properties
  
  /// The document's index.
  ///
  /// If the document has not yet been sent to Firestore, this value will be `nil`.
  var index: Int? { get set }
}

public extension IndexedDocument {
  
  // MARK: - Public Methods
  
  /**
   Sets the document in Firestore and updates the index singleton.
   
   - parameter completion: The completion handler.
   
   Documents are automatically stored in collections based on their type.
   
   If the pushed document has the same ID as an existing document in a collection, the old document will be replaced.
   */
  func set(completion: @escaping (Error?) -> Void = { _ in }) {
    Self.prepare(self) { newSelf, error in
      EasyFirestore.Storage.set(newSelf, completion: completion)
    }
  }
}

private extension IndexedDocument {
  
  // MARK: - Private Static Properties
  
  static var indexesDocument: DocumentReference {
    Firestore.firestore().collection("Singleton").document("_indexes")
  }
  
  // MARK: - Private Static Methods
  
  static func prepare<T>(_ document: T, completion: @escaping (T, Error?) -> Void) where T: IndexedDocument {
    guard document.index == nil else {
      completion(document, nil)
      return
    }
    var newDocument: T = document
    let fieldName = String(describing: Self.self)
    indexesDocument.getDocument { snapshot, error in
      newDocument.index = 0
      if let snapshot = snapshot, snapshot.exists {
        let count: Int? = snapshot.data()?[fieldName] as? Int
        if let count = count {
          newDocument.index = count + 1
        }
      } else {
        if let error = error {
          EasyFirebase.log(error: error)
        }
      }
      indexesDocument.setData([fieldName: newDocument.index!]) { error in
        completion(newDocument, error)
      }
    }
  }
}
