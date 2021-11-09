//
//  EasyFirestore.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

/// The name of a collection.
public typealias CollectionName = String

/**
 `EasyFirestore` is a service manager for various functions related to Firestore.
 
 To get started, check out the related structs.
 */
@available(macOS 10.15, iOS 13.0, *)
public struct EasyFirestore {
  
  // MARK: - Internal Static Properties
  
  internal static let db = Firestore.firestore()
  
  // MARK: - Internal Static Methods
  
  internal static func getArray<T>(from id: DocumentID, ofType type: T.Type, path: KeyPath<T, [DocumentID]>, completion: @escaping ([DocumentID]?) -> Void) where T: Document {
    db.collection(String(describing: type)).document(id).getDocument { result, _ in
      if let result = result, result.exists {
        let document = try? result.data(as: T.self)
        var array = document?[keyPath: path]
        if array == nil { array = [] }
        completion(array)
      } else {
        EasyFirebase.log(error: "Failed to load array of IDs from document [\(id)].")
      }
    }
  }
}
