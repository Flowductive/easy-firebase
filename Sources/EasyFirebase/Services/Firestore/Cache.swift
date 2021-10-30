//
//  File.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation

extension EasyFirestore {
  
  /**
   A service that helps send objects to Firestore.
   */
  public struct Cache<T> where T: Document {
    
    // MARK: - Private Static Properties
    
    private static var caches: [CollectionName: Cache] = [:]
    
    // MARK: - Private Properties
    
    private var cache: [DocumentID: T] = [:]
    
    // MARK: - Public Static Methods
    
    public static func register<T>(_ document: T) where T: Document {
      caches[document.typeName][document.id] = document
    }
    
    public static func grab<T>(_ id: DocumentID, fromType type: T.Type) -> T? where T: Document {
      return caches[String(describing: T)][id]
    }
    
    // MARK: - Private Methods
    
    private func grab(_ id: DocumentID) -> T? {
      guard let obj = cache[id] else { return nil }
      EasyFirebase.log("Document successfully retrieved from [\(obj.typeName)] cache. ID: \(id)")
      return store[id]
    }
    
    private func register(_ document: T) {
      cache[document.id] = document
      EasyFirebase.log("Document successfully stored in [\(document.typeName)] cache. ID: \(document.id) Size: \(store.count) object(s)")
    }
  }
}
