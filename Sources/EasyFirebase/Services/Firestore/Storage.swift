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
    
    public static func set<T>(_ document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      set(document, collection: document.typeName, id: document.id, completion: completion)
    }
    
    public static func set<T>(_ singleton: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Singleton {
      set(singleton, collection: "singleton", id: singleton.id, completion: completion)
    }
    
    // MARK: - Private Static Methods
    
    private static func set<T>(_ model: T, collection: CollectionName, id: String, completion: @escaping (Error?) -> Void = { _ in }) where T: Model {
      do {
        _ = try db.collection(collection).document(id).setData(from: model) { error in
          if let error = error {
            EasyFirebase.log(error: error)
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
