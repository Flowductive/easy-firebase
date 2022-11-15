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
  
  internal var batch: [BatchItem]? = .some([])
  private var location: Location?
  
  public private(set) var listener: ListenerRegistration? = nil
  
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

// MARK: - Document Location

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

// MARK: - Batching

extension Document {
  
  public func setBatch(completion: @escaping (Firestore.Error?) -> Void) {
    guard let batch = batch, !batch.isEmpty else {
      completion(.batchEmpty)
      return
    }
    firestoreDocumentReference.setData(batch.batchDict, merge: true) { error in
      self.handleWriteCompleted(error, handler: completion)
    }
  }
  
  internal struct BatchItem {
    var keyPath: String
    var newValue: Any
    var fieldValue: Any
  }
}

// MARK: - Read

extension Document {
  
  public static func read<T>(_ type: T.Type, id: Document.ID, from location: Location? = nil, completion: @escaping (Result<T, Firestore.Error>) -> Void) where T: Document {
    let _location: Location = getLocation(T.self, from: location)
    FirebaseFirestore.Firestore.firestore().collection(_location.rawValue).document(id).getDocument { snapshot, error in
      handleDocumentSnapshot(T.self, snapshot, error, from: _location, handler: completion)
    }
  }

  public static func read<T>(_ type: T.Type, ids: [Document.ID], from location: Location? = nil, onUpdate: @escaping (Result<Array<T>, Firestore.Error>) -> Void) where T: Document {
    let location: Location = getLocation(T.self, from: location)
    let chunks: [[Document.ID]] = ids.chunked(into: 10)
    for chunk in chunks {
      readChunk(type, chunk, from: location, onUpdate: onUpdate)
    }
  }
}

// MARK: - Listen

extension Document {
  
  public static func listen<T>(
    _ type: T.Type,
    id: Document.ID,
    from location: Location? = nil,
    onUpdate: @escaping (Result<T, Firestore.Error>) -> Void
  ) where T: Document {
    let _location: Location = getLocation(T.self, from: location)
    var listener: ListenerRegistration? = nil
    listener = FirebaseFirestore.Firestore.firestore().collection(_location.rawValue).document(id).addSnapshotListener { snapshot, error in
      handleDocumentSnapshot(T.self, snapshot, error, &listener, from: _location, handler: onUpdate)
    }
  }
  
  public static func listen<T>(
    _ type: T.Type,
    id: Document.ID,
    from location: Location? = nil,
    bindTo bindable: Binding<T?>,
    completion: @escaping (Firestore.Error?) -> Void = { _ in }
  ) where T: Document {
    let _location: Location = getLocation(T.self, from: location)
    var listener: ListenerRegistration? = nil
    listener = FirebaseFirestore.Firestore.firestore().collection(_location.rawValue).document(id).addSnapshotListener { snapshot, error in
      handleDocumentSnapshot(T.self, snapshot, error, &listener, from: _location) { result in
        guard let result = try? result.get() else {
          completion(.noDocument)
          return
        }
        completion(nil)
        bindable.wrappedValue = nil
        DispatchQueue.main.async { bindable.wrappedValue = result }
      }
    }
  }
}

// MARK: - Query

extension Document {
  
  struct Query {
    var condition: Condition
    
    struct Condition {
      
    }
  }
  
  public static func query<T>(
    _ type: T.Type,
    id: Document.ID,
    from location: Location? = nil,
    completion: @escaping (Result<Array<T>, Firestore.Error>) -> Void
  ) where T: Document {
    
  }
}

// MARK: - Write

extension Document {
  
  public func write(merge: Bool = false, completion: @escaping (Firestore.Error?) -> Void) {
    do {
      try firestoreDocumentReference.setData(from: self, merge: merge) { error in
        self.handleWriteCompleted(error, handler: completion)
      }
    } catch {
      completion(.encodingFailed)
    }
  }
}

// MARK: - Private Helper Methods

private extension Document {
  
  static func handleDocumentSnapshot<T>(
    _ type: T.Type,
    _ snapshot: DocumentSnapshot?,
    _ error: Error?,
    _ listener: UnsafeMutablePointer<ListenerRegistration?>? = nil,
    from location: Location,
    handler: @escaping (Result<T, Firestore.Error>) -> Void
  ) where T: Document {
    if error != nil {
      handler(.failure(.connection))
    } else if let snapshot, snapshot.exists {
      if let document = try? snapshot.data(as: T.self) {
        document.location = location
        document.listener = listener?.pointee
        handler(.success(document))
      } else {
        handler(.failure(.decodingFailed))
      }
    } else {
      handler(.failure(.noDocument))
    }
  }
  
  static func readChunk<T>(
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

  static func getLocation<T>(_ type: T.Type, from location: Location?) -> Location {
    var _location: Location
    if let location {
      _location = location
    } else {
      _location = .default(for: T.self)
    }
    return _location
  }
  
  func handleWriteCompleted(_ error: Error?, handler: @escaping (Firestore.Error?) -> Void) {
    if error != nil {
      handler(.connection)
      return
    } else {
      handler(nil)
    }
  }
}

