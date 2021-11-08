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

public typealias FieldName = String

extension EasyFirestore {
  
  public struct Storage {
    
    // MARK: - Public Static Methods
    
    public static func set<T>(_ document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
      set(document, collection: document.typeName, id: document.id, completion: completion)
    }
    
    public static func set<T>(_ singleton: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Singleton {
      set(singleton, collection: "singleton", id: singleton.id, completion: completion)
    }
    
    public static func set<T, U>(_ path: KeyPath<T, U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      let value = document[keyPath: path]
      db.collection(String(describing: T.self)).document(document.id).updateData([path.string: value], completion: completion)
    }
    
    public static func set<T, U>(_ value: U, to path: KeyPath<T, U>, in document: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Codable {
      set(path, in: document, completion: completion)
    }
    
    public static func setAssign<T, U>(_ document: T, to path: KeyPath<U, [DocumentID]>, in parent: U, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Document {
      set(document) { error in
        if let error = error {
          completion(error)
          return
        }
        Linking.assign(document, to: path, in: parent, completion: completion)
      }
    }
    
    // MARK: - Private Static Methods
    
    private static func set<T>(_ model: T, collection: CollectionName, id: String, completion: @escaping (Error?) -> Void) where T: Model {
      do {
        _ = try db.collection(collection).document(id).setData(from: model) { error in
          if let error = error {
            EasyFirebase.log(error: error.localizedDescription)
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
