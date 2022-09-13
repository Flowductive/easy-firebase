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
    
    internal static var codingKeys: [String] = []
    
    @Field public var id: String = UUID().uuidString
    @Field public var dateCreated: Date
    
    public init(id: String = UUID().uuidString, dateCreated: Date = Date()) {
      self.dateCreated = dateCreated
      for (label, value) in Mirror(reflecting: self).children {
        if let field = value as? AnyField, let label = label {
          field.inject(document: self, key: label)
        }
      }
    }
    
    public static func == (lhs: Document, rhs: Document) -> Bool {
      return lhs.id == rhs.id
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
}

@available(iOS 13.0, *)
public extension Firestore.Document {
  
  static func `get`(ids: [Firestore.Document.ID], from location: Location = .default, options: TransactionOptions? = nil, onUpdate: @escaping (Result<Array<Self>, Error>) -> Void) {
    
  }
  
  static func `get`(id: Firestore.Document.ID, from location: Location = .default, options: TransactionOptions? = nil, completion: @escaping (Result<Self, Error>) -> Void) {
    
  }
  
  func set(in location: Location = .default, options: TransactionOptions? = nil, completion: @escaping (Firestore.Error?) -> Void) {
    
  }
}
