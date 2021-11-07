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

extension EasyFirestore {
  
  public struct Removal {
    
    // MARK: - Public Static Methods
    
    public static func remove<T>(id: DocumentID, ofType type: T.Type, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      db.collection(String(describing: type)).document(id).delete { error in
        completion(error)
      }
    }
    
    public static func remove<T>(_ document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      remove(id: document.id, ofType: T.self, completion: completion)
    }
    
    public static func removeUnassign<T, U>(_ document: T, from field: FieldName, in parent: U, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Document {
      Linking.unassign(document, from: field, in: parent, completion: { error in
        if let error = error {
          completion(error)
          return
        }
        remove(document, completion: completion)
      })
    }
  }
}
