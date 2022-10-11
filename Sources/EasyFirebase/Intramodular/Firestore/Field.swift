//
//  File.swift
//  
//
//  Created by Ben Myers on 9/6/22.
//

import Combine
import Firebase
import Foundation
import FirebaseFirestore

// MARK: - Field Implementation

@propertyWrapper
public class Field<DocumentType, Value>: AnyField where Value: Codable, DocumentType: Firestore.Document {
  
  public typealias Output = Value
  
  public typealias Failure = Never
  
  public typealias Key = String
  
  public var wrappedValue: Value {
    willSet {
      document?.objectWillChange.send()
    }
  }
  
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
  
  public override func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
  
  internal override func decodeValue(from container: KeyedDecodingContainer<Firestore.Document.CodingKeys>, key propertyName: String) {
    guard let codingKey = Firestore.Document.CodingKeys(stringValue: key ?? propertyName) else { return }
    if let value = try? container.decodeIfPresent(Value.self, forKey: codingKey) {
      wrappedValue = value
    }
  }
  
  public required init(from decoder: Decoder) throws {
    self.wrappedValue = try Value(from: decoder)
    super.init(key: decoder.codingPath.map { $0.stringValue }.joined(separator: "."))
  }
  
  public var projectedValue: Field<DocumentType, Value> {
    self
  }
  
  public enum WriteOption: Equatable {
    
    /// Update locally, and in Firestore.
    case `default`
    
    /// Add this update to a batch.
    case batch
    
    /// Reverts the local write on fail.
    case revertOnFail
  }
}

extension Field {
  
  private func locallyUpdate(_ newValue: Value) {
    oldWrappedValue = wrappedValue
    wrappedValue = newValue
  }
  
  private func revertLocalUpdate() {
    guard let oldWrappedValue = oldWrappedValue else { return }
    wrappedValue = oldWrappedValue
    self.oldWrappedValue = nil
  }
  
  private func acceptLocalUpdate() {
    oldWrappedValue = nil
  }
}

// MARK: - Field Value Updating

extension Field {
  
  public func `set`(_ value: Value, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    update(value, value, option: option, completion: completion)
  }
}

extension Field where Value: ExpressibleByNilLiteral {
  
  public func remove(option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    update(nil, FieldValue.delete(), option: option, completion: completion)
  }
}

extension Field where Value: Sequence, Value.Element: Codable {
  
  public func append(_ newValue: Value.Element, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    append([newValue], option: option, completion: completion)
  }
  
  public func append(_ newValues: Array<Value.Element>, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    var arr: Array<Value.Element> = Array(wrappedValue)
    arr.append(contentsOf: newValues)
    guard let arr = arr as? Value else {
      completion(.unknown)
      return
    }
    update(arr, FieldValue.arrayUnion(newValues), option: option, completion: completion)
  }
}

extension Field where Value: BinaryInteger {
  
  public func increment(by difference: Value, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    update(wrappedValue + difference, FieldValue.increment(Double(difference)), option: option, completion: completion)
  }
}

extension Field {
  
  private func update(_ value: Value, _ fieldValue: Any, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    guard let key = key else { completion(.noKey); return }
    guard let document = document else { completion(.unknown); return }
    if option == .revertOnFail { locallyUpdate(value) }
    document.firestoreDocumentReference.updateData([key: fieldValue]) { error in
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
