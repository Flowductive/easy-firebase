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

extension EasyFirestore {
  
  /**
   A service that helps send objects to Firestore.
   */
  public struct Storage {
    
    // MARK: - Public Static Methods
    
    /**
     
     */
    public static func set<T>(_ document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      do {
        _ = try db.collection(document.typeName).document(document.id).setData(from: document) { error in
          if let error = error {
            EasyFirebase.log(error: error)
          } else {
            EasyFirebase.log("Document successfully sent to [\(document.typeName)] collection. ID: \(document.id)")
          }
          completion(error)
        }
      } catch {
        EasyFirebase.log(error: error)
      }
    }
  }
}
