//
//  Listening.swift
//  
//
//  Created by Ben Myers on 10/30/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@available(iOS 13.0, *)
extension EasyFirestore {
  
  /// A key categorizing Firebase `ListenerRegistration`s.
  public typealias ListenerKey = String
  
  /**
   A service for listening to data updates within documents.
   */
  public struct Listening {
    
    // MARK: - Private Static Properties
    
    private static var listeners: [ListenerKey: [ListenerRegistration?]] = [:]
    
    // MARK: - Public Static Methods
    
    public static func listen<T>(to id: DocumentID, ofType type: T.Type, key: ListenerKey, onUpdate: @escaping (T) -> Void) where T: Document {
      let listener = db.collection(String(describing: type)).document(id).addSnapshotListener { snapshot, _ in
        guard let snapshot = snapshot, snapshot.exists else {
          EasyFirebase.log(error: "A document with ID [\(id)] loaded from the [\(String(describing: type))] collection, but no data could be found.")
          return
        }
        var document: T?
        try? document = snapshot.data(as: T.self)
        guard let document = document else {
          EasyFirebase.log(error: "A document with ID [\(id)] loaded from the [\(String(describing: type))] collection, but couldn't be decoded.")
          return
        }
        onUpdate(document)
      }
      registerListener(listener, key: key)
    }
    
    // MARK: - Private Static Methods
    
    private static func registerListener(_ listener: ListenerRegistration, key: ListenerKey) {
      if listeners[key] != nil {
        listeners[key]!.append(listener)
      } else {
        listeners[key] = [listener]
      }
    }
  }
}
