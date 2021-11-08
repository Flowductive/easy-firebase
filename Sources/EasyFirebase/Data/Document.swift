//
//  Document.swift
//  
//
//  Created by Ben Myers on 10/28/21.
//

import Foundation

/// The ID of a document.
public typealias DocumentID = String

public protocol Document: Model, Equatable, Identifiable {
  
  // MARK: - Properties
  
  var id: String { get set }
  
  var dateCreated: Date { get }
}

extension Document {
  
  // MARK: - Public Methods
  
  public func set(completion: @escaping (Error?) -> Void = { _ in }) {
    EasyFirestore.Storage.set(self, completion: completion)
  }
  
  public func set<T>(_ path: KeyPath<Self, T>, completion: @escaping (Error?) -> Void = { _ in }) where T: Codable {
    EasyFirestore.Storage.set(path, in: self, completion: completion)
  }
  
  public mutating func set<T>(_ value: T, to path: WritableKeyPath<Self, T>, completion: @escaping (Error?) -> Void = { _ in }) where T: Codable {
    self[keyPath: path] = value
    EasyFirestore.Storage.set(value, to: path, in: self, completion: completion)
  }
  
  public func get<T>(_ path: KeyPath<Self, T>, completion: @escaping (T?) -> Void) where T: Codable {
    EasyFirestore.Retrieval.get(id: id, ofType: Self.self) { document in
      guard let document = document else {
        completion(nil)
        return
      }
      completion(document[keyPath: path])
    }
  }
  
  public func assign<T>(to path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
    EasyFirestore.Linking.assign(self, to: path, in: parent, completion: completion)
  }
  
  public func setAssign<T>(to path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
    EasyFirestore.Storage.setAssign(self, to: path, in: parent, completion: completion)
  }
  
  public func unassign<T>(from path: KeyPath<T, [DocumentID]>, in parent: T, completion: @escaping (Error?) -> Void = { _ in }) where T: Document {
    EasyFirestore.Linking.unassign(self, from: path, in: parent, completion: completion)
  }
}
