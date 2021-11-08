//
//  Cache.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation

extension EasyFirestore {
  
  /**
   A service that manages the cacheing of objects received from Firestore.
   
   You can specify whether you'd like to use EasyFirebase's cacheing capabilities by configuring the settings:
   
   ```swift
   EasyFirebase.useCache = true
   ```
   */
  public struct Cacheing {
    
    // MARK: - Fileprivate Static Properties
    
    fileprivate static var caches: [CollectionName: Any] = [:]
    
    // MARK: - Public Static Methods
    
    /**
     Registers a `Document` to the cache.
     
     - parameter document: The document to register.
     
     Registered documents are stored in caches based on their type.
     
     If `EasyFirebase.useCache` is set to `true`, documents retrieved from Firestore using `EasyFirestore.Retrieval` are automatically cached.
     
     To retrieve a cached object, use ``grab(_:fromType:)``.
     */
    public static func register<T>(_ document: T) where T: Document {
      guard let cache = Cacheing.caches[document.typeName] as? Cache<T> else { return }
      cache.register(document)
    }
    
    /**
     Grabs a cached `Document`.
     
     - parameter id: The ID of the document to grab.
     - parameter type: The document's type.
     
     Registered documents are stored in caches based on their type.
     
     You can specify whether you'd like to retrieve cached documents when retrieving objects with `EasyFirestore.Retrieval`.
     
     To store a local document, use ``register(_:)``.
     */
    public static func grab<T>(_ id: DocumentID, fromType type: T.Type) -> T? where T: Document {
      guard let cache = Cacheing.caches[String(describing: type)] as? Cache<T> else { return nil }
      return cache.grab(id)
    }
  }
  
  /**
   A cache for documents of a certain type.
   */
  public class Cache<T> where T: Document {
    
    // MARK: - Private Properties
    
    private var cache: [DocumentID: T] = [:]
    
    // MARK: - Fileprivate Methods
    
    fileprivate func grab(_ id: DocumentID) -> T? {
      guard let obj = cache[id] else { return nil }
      EasyFirebase.log("Document successfully retrieved from [\(obj.typeName)] cache. ID: \(id)")
      return cache[id]
    }
    
    fileprivate func register(_ document: T) {
      cache[document.id] = document
      EasyFirebase.log("Document successfully stored in [\(document.typeName)] cache. ID: \(document.id) Size: \(cache.count) object(s)")
    }
  }
}
