//
//  Document.swift
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
    
    class func defaultLocation() -> Location { .default }
    
    @Field public var id: String = UUID().uuidString
    @Field public var dateCreated: Date
    
    @CodableIgnored internal var batch: [Field.Key]? = .some([])
    @CodableIgnored private var fields: [Field.Key]? = .some([])
    @CodableIgnored private var location: Location?
  
    public init(id: String = UUID().uuidString, dateCreated: Date = Date()) {
      self.location = Self.defaultLocation()
      self.dateCreated = dateCreated
      for (label, value) in Mirror(reflecting: self).children {
        if let field = value as? AnyField, let label = label {
          fields?.append(label)
          field.inject(document: self, key: label)
        }
      }
    }
    
    internal func firestoreReference(_ location: Location? = nil) -> FirebaseFirestore.DocumentReference? {
      var _location: Location = .default
      if let location = location { _location = location }
      return FirebaseFirestore.Firestore.firestore().collection(_location.rawValue).document(id)
    }
    
    public static func == (lhs: Document, rhs: Document) -> Bool {
      return lhs.id == rhs.id
    }
  }
}

@available(iOS 13.0, *)
public extension Firestore.Document {
  
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
  
  static func read(ids: [Firestore.Document.ID], from location: Location = .default, onUpdate: @escaping (Result<Array<Self>, Error>) -> Void) {
    
  }
  
  static func read(id: Firestore.Document.ID, from location: Location = .default, completion: @escaping (Result<Self, Error>) -> Void) {
  }
  
  func write(to location: Location? = nil, completion: @escaping (Error?) -> Void = { _ in }) {
    
  }
}

@available(iOS 13.0, *)
internal extension Firestore.Document {
  
  func write(_ , completion: @escaping (Firestore.Error?) -> Void) {
    firestoreReference()?.getDocument(source: <#T##FirestoreSource#>, completion: <#T##(DocumentSnapshot?, Error?) -> Void#>)
  }
}
