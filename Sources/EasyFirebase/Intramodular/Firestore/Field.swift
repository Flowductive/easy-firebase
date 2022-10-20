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
public class Field<Parent, Value>: AnyField where Value: Codable, Parent: FieldObject {
  
  public typealias Output = Value
  
  public typealias Failure = Never
  
  public typealias Key = String
  
  public var wrappedValue: Value {
    willSet {
      parent?.objectWillChange.send()
    }
  }
  
  public unowned var parent: Parent?
  
  public override var valueAsAny: Any { wrappedValue as Any }
  
  public override var parentAsAny: Any? {
    get {
      parent as Any
    } set {
      guard let newValue = newValue, let newParent = newValue as? Parent else { return }
      parent = newParent
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
  
  internal override func decodeValue(from container: KeyedDecodingContainer<Document.CodingKeys>, key propertyName: String) {
    guard let codingKey = Document.CodingKeys(stringValue: key ?? propertyName) else { return }
    if let value = try? container.decodeIfPresent(Value.self, forKey: codingKey) {
      wrappedValue = value
    }
  }
  
  public required init(from decoder: Decoder) throws {
    self.wrappedValue = try Value(from: decoder)
    super.init(key: decoder.codingPath.map { $0.stringValue }.joined(separator: "."))
  }
  
  public var projectedValue: Field<Parent, Value> {
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
    guard let keyPath = keyPath else { completion(.noKey); return }
    guard let document = parent?.enclosingDocument else { completion(.unknown); return }
    if option == .revertOnFail { locallyUpdate(value) }
    document.firestoreDocumentReference.updateData([keyPath: fieldValue]) { error in
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
