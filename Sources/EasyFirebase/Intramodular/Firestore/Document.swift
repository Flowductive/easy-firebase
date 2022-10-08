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

public extension Firestore {
  
  typealias Collection = String
  
  class Document: Codable, Identifiable, Equatable {
    
    @Field public var id: String = UUID().uuidString
    @Field public var dateCreated: Date
    
    @CodableIgnored internal var batch: [Field.Key]? = .some([])
    @CodableIgnored private var fields: [Field.Key]? = .some([])
    @CodableIgnored private var location: Location?
    
    internal var firestoreCollectionReference: FirebaseFirestore.CollectionReference {
      let location: Location = Self.getLocation(from: location)
      return FirebaseFirestore.Firestore.firestore().collection(location.rawValue)
    }
    
    internal var firestoreDocumentReference: FirebaseFirestore.DocumentReference {
      return firestoreCollectionReference.document(id)
    }
  
    public init(id: String = UUID().uuidString, dateCreated: Date = Date()) {
      self.location = Location.default(for: Self.self)
      self.dateCreated = dateCreated
      for (label, value) in Mirror(reflecting: self).children {
        if let field = value as? AnyField, let label = label {
          fields?.append(label)
          field.inject(document: self, key: label)
        }
      }
    }
    
    public static func == (lhs: Document, rhs: Document) -> Bool {
      return lhs.id == rhs.id
    }
  }
}

public extension Firestore.Document {
  
  struct Location: RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
      self.rawValue = rawValue
    }
    
    public static func collection(_ name: String) -> Self {
      Self(rawValue: name)
    }
    
    public static func subcollection(path descendingCollectionNames: String...) -> Self {
      Self(rawValue: descendingCollectionNames.joined(separator: "."))
    }
    
    internal static func `default`<T>(for documentType: T.Type) -> Self {
      Self(rawValue: String(describing: T.self))
    }
  }
}

public extension Firestore.Document {
  
  static func read(id: Firestore.Document.ID, from location: Location? = nil, completion: @escaping (Result<Self, Firestore.Error>) -> Void) {
    let _location: Location = getLocation(from: location)
    FirebaseFirestore.Firestore.firestore().collection(_location.rawValue).document(id).getDocument { snapshot, error in
      if error != nil {
        completion(.failure(.connection))
      } else if let snapshot, snapshot.exists {
        if let document = try? snapshot.data(as: Self.self) {
          document.location = location
          completion(.success(document))
        } else {
          completion(.failure(.decodingFailed))
        }
      } else {
        completion(.failure(.noDocument))
      }
    }
  }

  static func read(ids: [Firestore.Document.ID], from location: Location? = nil, onUpdate: @escaping (Result<Array<Self>, Firestore.Error>) -> Void) {
    let location: Location = getLocation(from: location)
    let chunks: [[Firestore.Document.ID]] = ids.chunked(into: 10)
    for chunk in chunks {
      readChunk(chunk, from: location, onUpdate: onUpdate)
    }
  }

  private static func readChunk(
    _ chunk: [Firestore.Document.ID],
    from location: Location,
    onUpdate: @escaping (Result<Array<Self>, Firestore.Error>) -> Void
  ) {
    FirebaseFirestore.Firestore.firestore().collection(location.rawValue).whereField("id", in: chunk).getDocuments { snapshot, error in
      if error != nil {
        onUpdate(.failure(.connection))
        return
      } else if let snapshot, !snapshot.isEmpty {
        var arr: [Self] = []
        for document in snapshot.documents {
          let object = try? document.data(as: Self.self)
          if let object {
            object.location = location
            arr.append(object)
          }
        }
        onUpdate(.success(arr))
      } else {
        onUpdate(.failure(.noDocument))
      }
    }
  }

  private static func getLocation(from location: Location?) -> Location {
    var _location: Location
    if let location {
      _location = location
    } else {
      _location = .default(for: Self.self)
    }
    return _location
  }
}

internal extension Firestore.Document {
  
  func setBatch(completion: @escaping (Firestore.Error?) -> Void) {
    guard let batch = batch, !batch.isEmpty else {
      completion(.batchEmpty)
      return
    }
    do {
      try firestoreDocumentReference.setData(from: self, mergeFields: batch) { error in
        if error != nil {
          completion(.connection)
          return
        } else {
          completion(nil)
        }
      }
    } catch {
      completion(.encodingFailed)
    }
  }
  
  func write(merge: Bool = false, completion: @escaping (Firestore.Error?) -> Void) {
    do {
      try firestoreDocumentReference.setData(from: self, merge: merge) { error in
        if error != nil {
          completion(.connection)
          return
        }
      }
    } catch {
      completion(.encodingFailed)
    }
  }
}

fileprivate extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}
