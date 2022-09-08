//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Firebase
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

@available(iOS 13.0, *)
public extension Firestore {
  
  class Document: Codable, Identifiable, Equatable {
    
    open static var properties: [String, Any]
    
    @Field public var id: String
    public var dateCreated: Date
    
    public init(id: ID = UUID().uuidString, dateCreated: Date = Date()) {
      id = @Field(wrappedValue: id)
      self.dateCreated = dateCreated
    }
    
    public static func == (lhs: Document, rhs: Document) -> Bool {
      return lhs.id == rhs.id
    }
    
    public struct CodingKeys: CodingKey {
      
      public var stringValue: String
      
      public init?(stringValue: String) {
        self.stringValue = stringValue
      }
      
      public var intValue: Int? {
        var hasher = Hasher()
        stringValue.hash(into: &hasher)
        return hasher.finalize()
      }
      
      public init?(intValue: Int) {
        nil
      }
    }
    
    public func test() {
      let mirror = Mirror(reflecting: self)
      let dict: [String: Any]
      for child in mirror.children {
        if let wrappedValue
        dict.updateValue(child.value, forKey: child.label)
      }
    }
  }
}

@available(iOS 13.0, *)
public extension Firestore.Document {
  
  struct TransactionOptions {
    
    public var cache: Bool
    
    public init(cache: Bool = true) {
      self.cache = cache
    }
  }
  
  struct Location: RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
      self.rawValue = rawValue
    }
    
    public static var `default`: Self {
      Self(rawValue: String(describing: type(of: self)))
    }
    
    public static func collection(_ name: String) -> Self {
      Self(rawValue: name)
    }
    
    public static func subcollection(path descendingCollectionNames: String...) -> Self {
      
      Self(rawValue: descendingCollectionNames.joined(separator: "."))
    }
  }
  
  enum Error: LocalizedError {
  }
}

@available(iOS 13.0, *)
public extension Firestore.Document {
  
  // MARK: - Static Methods
  
  static func `get`(ids: [Firestore.Document.ID], from location: Location = .default, options: TransactionOptions? = nil, onUpdate: @escaping (Result<Array<Self>, Error>) -> Void) {
    
  }
  
  static func `get`(id: Firestore.Document.ID, from location: Location = .default, options: TransactionOptions? = nil, completion: @escaping (Result<Self, Error>) -> Void) {
    
  }
  
  // MARK: - Methods
  
  final func set(in location: Location = .default, options: TransactionOptions? = nil, completion: @escaping (Firestore.Document.Error?) -> Void) {
    
  }
}
