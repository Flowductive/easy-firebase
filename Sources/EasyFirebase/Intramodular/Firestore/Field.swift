//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Foundation
import Firebase
import FirebaseFirestore

@propertyWrapper
public class Field<DocumentType, Value>: AnyField, Codable where Value: Codable, DocumentType: Firestore.Document {
  
  public typealias Key = String
  
  public internal(set) var wrappedValue: Value
  
  public unowned var document: DocumentType?
  
  public override var valueAsAny: Any { wrappedValue as Any }
  
  public override var documentAsAny: Any? {
    get {
      document as Any
    } set {
      guard let newValue = newValue, let newDoc = newValue as? DocumentType else { return }
      document = newDoc
    }
  }
  
  private var oldWrappedValue: Value?
  
  public init(wrappedValue defaultValue: Value, _ key: Key? = nil) {
    self.wrappedValue = defaultValue
    super.init(key: key)
  }
  
  public func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
  
  public required init(from decoder: Decoder) throws {
    self.wrappedValue = try Value(from: decoder)
    super.init(key: decoder.codingPath.map { $0.stringValue }.joined(separator: "."))
  }
  
  public var projectedValue: Field<DocumentType, Value> {
    self
  }
  
  public enum WriteOption: Equatable {
    
    /// Adds this write to the batch.
    case batch
    
    /// Reverts the local write on fail.
    case revertOnFail
  }
}

internal extension Field {
  
  func locallyUpdate(_ newValue: Value) {
    oldWrappedValue = wrappedValue
    wrappedValue = newValue
  }
  
  func revertLocalUpdate() {
    guard let oldWrappedValue = oldWrappedValue else { return }
    wrappedValue = oldWrappedValue
    self.oldWrappedValue = nil
  }
  
  func acceptLocalUpdate() {
    oldWrappedValue = nil
  }
}

public extension Field {
  
  func `set`(_ value: Value, option: WriteOption = .revertOnFail, completion: @escaping (Firestore.Error?) -> Void) {
    guard let key = key else { completion(.noKey); return }
    guard let document = document else { completion(.unknown); return }
    locallyUpdate(value)
    document.firestoreDocumentReference.updateData([key: value]) { error in
      if error != nil {
        completion(.connection)
        self.revertLocalUpdate()
      } else {
        completion(nil)
        self.acceptLocalUpdate()
      }
    }
  }
}

public extension Field where Value == Double {
  
  func increment(by value: Value, option: WriteOption = .revertOnFail, completion: @escaping (Firestore.Error?) -> Void) {
    guard let key = key else { completion(.noKey); return }
    guard let document = document else { completion(.unknown); return }
    locallyUpdate(value)
    document.firestoreDocumentReference.updateData([key: FieldValue.increment(value)]) { error in
      if error != nil {
        completion(.connection)
        self.revertLocalUpdate()
      } else {
        completion(nil)
        self.acceptLocalUpdate()
      }
    }
  }
}

public extension Field where Value == Int {
  
  func increment(by value: Value, option: WriteOption = .revertOnFail, completion: @escaping (Firestore.Error?) -> Void) {
    guard let key = key else { completion(.noKey); return }
    guard let document = document else { completion(.unknown); return }
    locallyUpdate(value)
    document.firestoreDocumentReference.updateData([key: FieldValue.increment(Double(value))]) { error in
      if error != nil {
        completion(.connection)
        self.revertLocalUpdate()
      } else {
        completion(nil)
        self.acceptLocalUpdate()
      }
    }
  }
}
