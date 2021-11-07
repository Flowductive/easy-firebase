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

public typealias CollectionName = String

/**
 A Swift wrapper for Firebase Firestore's methods.
 
 `EasyFirestore` is a great solution for object sending and retrieval to/from Firestore.
 
 To send objects to Firestore, define a class that conforms to `Document`:
 
 ```
 class Car: Document {
   var id: String = UUID().uuidString
   var dateCreated: Date = Date()
   var make: String
   var model: String
   // ...
 }
 ```
 
 Then, push it to Firestore using the `Document.push()` method:
 
 ```
 var car = Car("Toyota", "Corolla")
 car.push()
 ```
 
 This will automatically push the `car` object to a collection named `"car"`.
 
 For more information about the various services offered by `EasyFirestore`, check out:
 
 - ``Storage``
 */
@available(macOS 10.15, *)
public struct EasyFirestore {
  
  // MARK: - Internal Static Properties
  
  internal static let db = Firestore.firestore()
  
  // MARK: - Internal Static Methods
  
  internal static func getArray<T>(from id: DocumentID, ofType type: T.Type, field: FieldName, completion: @escaping ([DocumentID]?) -> Void) where T: Document {
    db.collection(String(describing: type)).document(id).getDocument { result, _ in
      if let result = result, result.exists {
        let item = result.get(field)
        var array = item as? [DocumentID]
        if array == nil { array = [] }
        completion(array)
      } else {
        EasyFirebase.log(error: "Failed to load array of IDs from document [\(id)].")
      }
    }
  }
}
