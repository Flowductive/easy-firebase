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

@available(iOS 13.0, *)
extension EasyFirestore {
  
  /**
   A service used to retrieve documents from Firestore.
   */
  public struct Retrieval {
    
    // MARK: - Public Static Methods
    
    /**
     Gets a document from Firestore.
     
     - parameter id: The ID of the document to retrieve.
     - parameter type: The document's type.
     - parameter useCache: Whether the cache should be prioritized to grab documents (if they exist).
     - parameter completion: The completion handler.
     
     Objects retrieved from Firestore are retrieved from collections based on their type.
     */
    public static func get<T>(id: DocumentID, ofType type: T.Type, useCache: Bool = EasyFirebase.useCache, completion: @escaping (T?) -> Void) where T: Document {
      if useCache, let cachedDocument = Cacheing.grab(id, fromType: type) {
        completion(cachedDocument)
        return
      } else {
        get(id, collection: String(describing: type), type: type, completion: completion)
      }
    }
    
    /**
     Gets a singleton from Firestore.
     
     - parameter singleton: The name of the singleton to retrieve.
     - parameter type: The singleton's type.
     - parameter completion: The completion handler.
     
     Singletons retrieved from Firestore are retrieved from the `Singleton` collection.
     */
    public static func get<T>(singleton: SingletonName, ofType type: T.Type, completion: @escaping (T?) -> Void) where T: Singleton {
      get(singleton, collection: "Singleton", type: type, completion: completion)
    }
    
    /**
     Gets an array of documents from Firestore.
     
     - parameter ids: An array of `DocumentID`s to retrieve.
     - parameter type: The documents' type.
     - parameter useCache: Whether the cache should be prioritized to grab documents (if they exist).
     - parameter onFetch: The fetch handler. When documents are fetched, they'll populate here.
     */
    public static func get<T>(ids: [DocumentID], ofType type: T.Type, useCache: Bool = EasyFirebase.useCache, onFetch: @escaping ([T]) -> Void) where T: Document {
      guard ids.count > 0 else {
        onFetch([])
        return
      }
      let chunks = ids.chunk(size: 10)
      var results: [T] = []
      for chunk in chunks {
        get(chunk: chunk, ofType: type, useCache: useCache) { arr in
          results <= arr
          onFetch(results)
        }
      }
    }
    
    /**
     Gets an array of documents from Firestore based on a list of `DocumentID`s from some parent document.
     
     - parameter path: The path of the parent document's field containing the list of `DocumentID`s.
     - parameter parent: The parent document containing the list of `DocumentID`s.
     - parameter type: The type of documents that are being retrieved.
     - parameter useCache: Whether the cache should be prioritized to grab documents (if they exist).
     - parameter onFetch: The fetch handler. When documents are fetched, they'll populate here.
     */
    public static func getChildren<T, U>(from path: KeyPath<U, [DocumentID]>, in parent: U, ofType: T.Type, useCache: Bool = EasyFirebase.useCache, onFetch: @escaping ([U]) -> Void) where T: Document, U: Document {
      EasyFirestore.getArray(from: parent.id, ofType: U.self, path: path) { ids in
        guard let ids = ids else {
          onFetch([])
          return
        }
        get(ids: ids, ofType: U.self, onFetch: onFetch)
      }
    }
    
    // MARK: - Private Static Methods
    
    private static func get<T>(_ id: String, collection: CollectionName, type: T.Type, completion: @escaping (T?) -> Void) where T: Document {
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
          Cacheing.register(document)
        }
        completion(document)
      }
    }
    
    private static func get<T>(chunk: [DocumentID], ofType type: T.Type, useCache: Bool, completion: @escaping ([T]) -> Void) where T: Document {
      guard chunk.count > 0, chunk.count <= 10 else {
        completion([])
        return
      }
      var cachedDocuments: [T] = []
      var newIDs: [DocumentID] = chunk
      if useCache {
        for id in chunk {
          if let cachedDocument = Cacheing.grab(id, fromType: T.self) {
            cachedDocuments <= cachedDocument
            newIDs -= id
          }
        }
      }
      guard newIDs.count > 0 else {
        completion(cachedDocuments)
        return
      }
      db.collection(String(describing: type)).whereField("id", in: newIDs).getDocuments { snapshot, error in
        var toReturn: [T] = []
        toReturn <= cachedDocuments
        if let error = error {
          EasyFirebase.log(error: error.localizedDescription)
          completion(cachedDocuments)
          return
        }
        let documents = snapshot?.documents ?? []
        let objects: [T] = documents.compactMap { doc in
          let item = try? doc.data(as: T.self)
          if let item = item {
            Cacheing.register(item)
          }
          return item
        }
        toReturn <= objects
        completion(toReturn)
      }
    }
  }
}
