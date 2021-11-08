//
//  Cache.swift
//  
//
//  Created by Ben Myers on 10/29/21.
//

import Foundation

extension EasyFirestore {
  
  public struct Cacheing {
    
    // MARK: - Fileprivate Static Properties
    
    fileprivate static var caches: [CollectionName: Any] = [:]
    
    // MARK: - Public Static Methods
    
    public static func register<T>(_ document: T) where T: Document {
      guard let cache = Cacheing.caches[document.typeName] as? Cache<T> else { return }
      cache.register(document)
    }
    
    public static func grab<T>(_ id: DocumentID, fromType type: T.Type) -> T? where T: Document {
      guard let cache = Cacheing.caches[String(describing: type)] as? Cache<T> else { return nil }
      return cache.grab(id)
    }
  }
  
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
