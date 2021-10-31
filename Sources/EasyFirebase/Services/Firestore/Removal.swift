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
    
    public static func remove<T>(id: DocumentID, ofType type: T.Type, completion: @escaping () -> Void) where T: Document {
      db.collection(String(describing: type)).document(id).delete { error in
        if let error = error {
          EasyFirebase.log(error: error.localizedDescription)
        }
        completion()
      }
    }
    
    public static func remove<T>(_ document: T, completion: @escaping () -> Void) where T: Document {
      remove(id: document.id, ofType: T.self, completion: completion)
    }
  }
}
