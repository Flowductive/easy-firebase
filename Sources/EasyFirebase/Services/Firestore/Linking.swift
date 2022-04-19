//
//  Linking.swift
//  
//
//  Created by Ben Myers on 11/2/21.
//

import Foundation

@available(iOS 13.0, *)
extension EasyFirestore {
  
  /**
   A service that manages linking a document's ID to a list of `DocumentID`s in a parent document.
   */
  public struct Linking {
    
    // MARK: - Public Static Methods
    
    /**
     Assigns a document's ID to a list of `DocumentID`s in the parent document.
     
     - parameter child: The child document (only used to get an ID).
     - parameter path: The path of the parent document's field containing the list of `DocumentID`s.
     - parameter parent: The parent document containing the list of `DocumentID`s.
     - parameter completion: The completion handler.
     */
    public static func assign<T, U>(_ child: T, toField field: FieldName, using path: KeyPath<U, [DocumentID]>, in parent: U, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Document {
      append(child.id, field: field, using: path, in: parent, completion: completion)
    }
    
    /**
     Unassigns a document's ID from a list of `DocumentID`s in the parent document.
     
     - parameter child: The child document (only used to get an ID).
     - parameter path: The path of the parent document's field containing the list of `DocumentID`s.
     - parameter parent: The parent document containing the list of `DocumentID`s.
     - parameter completion: The completion handler.
     */
    public static func unassign<T, U>(_ child: T, fromField field: FieldName, using path: KeyPath<U, [DocumentID]>, in parent: U, completion: @escaping (Error?) -> Void = { _ in }) where T: Document, U: Document {
      unappend(child.id, field: field, using: path, in: parent, completion: completion)
    }
    
    // MARK: - Private Static Methods
    
    private static func append<T>(_ id: DocumentID, field: FieldName, using path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void) where T: Document {
      getArray(from: parent.id, ofType: T.self, path: path) { array in
        guard var array = array else {
          completion(LinkingError.noArray)
          return
        }
        array <= id
        Storage.set(field: field, with: array, using: path, in: parent, completion: completion)
      }
    }
    
    private static func unappend<T>(_ id: DocumentID, field: FieldName, using path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void) where T: Document {
      getArray(from: id, ofType: T.self, path: path) { array in
        guard var array = array else {
          completion(LinkingError.noArray)
          return
        }
        array -= id
        Storage.set(field: field, with: array, using: path, in: parent, completion: completion)
      }
    }
    
    // MARK: - Enumerations
    
    enum LinkingError: Error {
      case noArray
    }
  }
}
