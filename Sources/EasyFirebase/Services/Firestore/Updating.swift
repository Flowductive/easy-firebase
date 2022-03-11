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
    public static func increment<T, U>(_ path: KeyPath<T, U?>, by increase: Int, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: AdditiveArithmetic {
      let collectionName = String(describing: T.self)
      db.collection(collectionName).document(document.id).updateData([path.string: FieldValue.increment(Int64(increase))], completion: completion)
    }
  }
}
