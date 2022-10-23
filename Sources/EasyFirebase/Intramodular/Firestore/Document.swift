//
//  Document.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import SwiftUI
import Firebase
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

open class Document: FieldObject, Identifiable, Equatable {
  
  @Field public var id: String
  @Field public var dateCreated: Date
  
  internal var batch: [Field.Key]? = .some([])
  private var location: Location?
  
  internal var firestoreCollectionReference: FirebaseFirestore.CollectionReference {
    let location: Location = Self.getLocation(Self.self, from: location)
    return FirebaseFirestore.Firestore.firestore().collection(location.rawValue)
  }
  
  internal var firestoreDocumentReference: Firebase.DocumentReference {
    return firestoreCollectionReference.document(id)
  }

  public init(id: String = UUID().uuidString, dateCreated: Date = Date()) {
    self.id = id
    self.location = Location.default(for: Self.self)
    self.dateCreated = dateCreated
    super.init()
  }
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .init(stringValue: "id")!)
    dateCreated = (try? container.decode(Date.self, forKey: .init(stringValue: "dateCreated")!)) ?? Date()
    try super.init(from: decoder)
    var mirror: Mirror? = Mirror(reflecting: self)
    repeat {
      guard let children = mirror?.children else { break }
      for child in children {
        if let field = child.value as? AnyField,
           let label = child.label?.underscorePrefixRemoved()
        {
          fields?.append(label)
          field.inject(parent: self, key: label)
          field.decodeValue(from: container)
        }
      }
      mirror = mirror?.superclassMirror
    } while mirror != nil
  }
  
  public static func == (lhs: Document, rhs: Document) -> Bool {
    return lhs.id == rhs.id
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container: KeyedEncodingContainer = encoder.container(keyedBy: CodingKeys.self)
    var mirror: Mirror? = Mirror(reflecting: self)
    repeat {
      guard let children = mirror?.children else { break }
      for child in children {
        guard let value = child.value as? Encodable else { continue }
        guard value is AnyField else { continue }
        let propertyName = child.label?.underscorePrefixRemoved() ?? ""
        if let key = CodingKeys(stringValue: propertyName) {
          try? container.encode(value, forKey: key)
        }
      }
      mirror = mirror?.superclassMirror
    } while mirror != nil
  }
}

extension Document {
  
  public struct Location: RawRepresentable {
    
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

extension Document {
  
  public static func read<T>(_ type: T.Type, id: Document.ID, from location: Location? = nil, completion: @escaping (Result<T, Firestore.Error>) -> Void) where T: Document {
    let _location: Location = getLocation(T.self, from: location)
    FirebaseFirestore.Firestore.firestore().collection(_location.rawValue).document(id).getDocument { snapshot, error in
      if error != nil {
        completion(.failure(.connection))
      } else if let snapshot, snapshot.exists {
        if let document = try? snapshot.data(as: T.self) {
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

  public static func read<T>(_ type: T.Type, ids: [Document.ID], from location: Location? = nil, onUpdate: @escaping (Result<Array<T>, Firestore.Error>) -> Void) where T: Document {
    let location: Location = getLocation(T.self, from: location)
    let chunks: [[Document.ID]] = ids.chunked(into: 10)
    for chunk in chunks {
      readChunk(type, chunk, from: location, onUpdate: onUpdate)
    }
  }

  private static func readChunk<T>(
    _ type: T.Type,
    _ chunk: [Document.ID],
    from location: Location,
    onUpdate: @escaping (Result<Array<T>, Firestore.Error>) -> Void
  ) where T: Document {
    FirebaseFirestore.Firestore.firestore().collection(location.rawValue).whereField("id", in: chunk).getDocuments { snapshot, error in
      if error != nil {
        onUpdate(.failure(.connection))
        return
      } else if let snapshot, !snapshot.isEmpty {
        
        var arr: [T] = []
        for document in snapshot.documents {
          let object = try? document.data(as: T.self)
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

  private static func getLocation<T>(_ type: T.Type, from location: Location?) -> Location {
    var _location: Location
    if let location {
      _location = location
    } else {
      _location = .default(for: T.self)
    }
    return _location
  }
}

extension Document {
  
  public func setBatch(completion: @escaping (Firestore.Error?) -> Void) {
    guard let batch = batch, !batch.isEmpty else {
      completion(.batchEmpty)
      return
    }
    self.batch = []
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
  
  public func write(merge: Bool = false, completion: @escaping (Firestore.Error?) -> Void) {
    do {
      try firestoreDocumentReference.setData(from: self, merge: merge) { error in
        if error != nil {
          completion(.connection)
          return
        } else {
          completion(nil)
          return
        }
      }
    } catch {
      completion(.encodingFailed)
    }
  }
}

