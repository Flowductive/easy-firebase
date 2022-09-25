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
 
 To get started, check out the related structs:
 
 - ``Cache``
 - ``Linking``
 - ``Listening``
 - ``Removal``
 - ``Retrieval``
 - ``Storage``
 */
@available(macOS 10.15, iOS 13.0, *)
public struct EasyFirestore {

  // MARK: - Public Static Properties

  public static let usePersistence: Bool = false
  
  // MARK: - Internal Static Properties
  
  internal static let db = Firestore.firestore()
  
  // MARK: - Internal Static Methods
  
  internal static func getArray<T>(from id: T.ID, ofType type: T.Type, path: KeyPath<T, [String]>, completion: @escaping ([String]?) -> Void) where T: Document {
    db.collection(colName(of: T.self)).document(id).getDocument { result, _ in
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
  
  internal static func colName<T>(of type: T.Type) -> CollectionName {
    var str = String(describing: T.self)
    if let dotRange = str.range(of: ".") {
      str.removeSubrange(str.startIndex ..< dotRange.lowerBound)
    }
    return str
  }
}
