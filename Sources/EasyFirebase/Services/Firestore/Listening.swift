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
    
    /**
     Listen to document updates.
     
     - parameter id: The document's ID.
     - parameter type: The document's type.
     - parameter key: The listener key to attach.
     - parameter onUpdate: The update handler. If `nil` is passed, the document has been deleted.
     */
    public static func listen<T>(to id: T.ID, ofType type: T.Type, key: ListenerKey, onUpdate: @escaping (T?) -> Void) where T: Document {
      let docRef = db.collection(colName(of: T.self)).document(id)
      listen(using: docRef, ofType: T.self, key: key, onUpdate: onUpdate)
    }
    
    /**
     Listen to singleton document updates.
     
     - parameter singleton: The singleton's type.
     - parameter key: The listener key to attach.
     - parameter onUpdate: The update handler. If `nil` is passed, the document has been deleted.
     */
    public static func listen<T>(singleton: T.Type, key: ListenerKey, onUpdate: @escaping (T?) -> Void) where T: Singleton {
      let docRef = db.collection("Singleton").document(colName(of: T.self))
      listen(using: docRef, ofType: T.self, key: key, onUpdate: onUpdate)
    }
    
    /**
     Stop listening to document updates.
     
     - parameter key: The key to stop listening to.
     */
    public static func stop(_ key: ListenerKey) {
      guard let keyListeners: [ListenerRegistration?] = listeners[key] else { return }
      for listener in keyListeners {
        listener?.remove()
      }
    }
    
    /**
     Stops all document listeners.
     */
    public static func stopAll() {
      for listener in listeners.keys {
        stop(listener)
      }
    }
    
    // MARK: - Private Static Methods
    
    private static func listen<T>(using ref: DocumentReference, ofType type: T.Type, key: ListenerKey, onUpdate: @escaping (T?) -> Void) where T: Document {
      let listener = ref.addSnapshotListener { snapshot, _ in
        guard let snapshot = snapshot, snapshot.exists else {
          EasyFirebase.log(error: "A document loaded from the [\(colName(of: T.self))] collection, but no data could be found.")
          onUpdate(nil)
          return
        }
        var document: T?
        if snapshot.data() == nil {
          onUpdate(nil)
        }
        do {
          try document = snapshot.data(as: T.self)
        } catch {
          print(error.localizedDescription)
          return
        }
        guard let document = document else {
          EasyFirebase.log(error: "A document loaded from the [\(colName(of: T.self))] collection, but couldn't be decoded.")
          return
        }
        onUpdate(document)
      }
      registerListener(listener, key: key)
    }
    
    private static func registerListener(_ listener: ListenerRegistration, key: ListenerKey) {
      if listeners[key] != nil {
        listeners[key]!.append(listener)
      } else {
        listeners[key] = [listener]
      }
    }
  }
}
