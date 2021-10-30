//
//  Retrieval.swift
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
  public struct Retrieval {
    
    // MARK: - Public Static Methods
    
    public static func get<T>(id: DocumentID, ofType type: T.Type, useCache: Bool = EasyFirebase.useCache, completion: @escaping (T?) -> Void) where T: Document {
      if useCache, let cachedDocument = Cache.grab(id, fromType: type) {
        completion(cachedDocument)
        return
      } else {
        get(id, collection: String(describing: type), type: type, completion: completion)
      }
    }
    
    public static func get<T>(singleton: SingletonName, ofType type: T.Type, completion: @escaping (T?) -> Void) where T: Singleton {
      get(singleton, collection: "singleton", type: type, completion: completion)
    }
    
    // MARK: - Private Static Methods
    
    private static func get<T>(_ id: String, collection: CollectionName, type: T.Type, completion: @escaping (T?) -> Void) where T: Model {
      db.collection(collection).document(id).getDocument { result, error in
        var document: T?
        if let result = result, result.exists {
          try? document = result.data(as: type)
        } else if let error = error {
          EasyFirebase.log(error.localizedDescription)
        } else {
          EasyFirebase.log(error: "The document with ID [\(id)] could not be loaded from the [\(String(describing: type))] collection.")
        }
        if let document = document {
          Cache.register(document)
        }
        completion(document)
      }
    }
  }
}
