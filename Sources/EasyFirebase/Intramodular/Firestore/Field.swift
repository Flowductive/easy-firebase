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
public class Field<Parent, Value>: AnyField<Parent> where Value: Codable, Parent: FieldObject {
  
  public typealias Output = Value
  
  public typealias Failure = Never
  
  public typealias Key = String
  
  public var wrappedValue: Value {
    willSet {
      parent?.objectWillChange.send()
    }
  }
  
  public override var valueAsAny: Any { wrappedValue as Any }
  
  private var oldWrappedValue: Value?
  
  public init(wrappedValue defaultValue: Value, _ key: Key? = nil) {
    self.wrappedValue = defaultValue
    super.init(key: key)
  }
  
  public override func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
  
  internal override func decodeValue(from container: KeyedDecodingContainer<FieldObject.CodingKeys>) {
    guard let key, let codingKey = FieldObject.CodingKeys(stringValue: key) else { return }
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

extension Field where Value: Sequence, Value.Element: Codable, Value.Element: Equatable {
  
  public func union(_ newValue: Value.Element, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    union([newValue], option: option, completion: completion)
  }
  
  public func union(_ newValues: Array<Value.Element>, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    var arr: Array<Value.Element> = Array(wrappedValue)
    arr.appendUniquely(contentsOf: newValues)
    guard let arr = arr as? Value else {
      completion(.unknown)
      return
    }
    update(arr, FieldValue.arrayUnion(newValues), option: option, completion: completion)
  }
  
  public func remove(_ value: Value.Element, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    remove([value], option: option, completion: completion)
  }
  
  public func remove(_ values: Array<Value.Element>, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    var arr: Array<Value.Element> = Array(wrappedValue)
    arr.removeAll(of: values)
    guard let arr = arr as? Value else {
      completion(.unknown)
      return
    }
    update(arr, FieldValue.arrayRemove(values), option: option, completion: completion)
  }
}

extension Field where Value == Double {
  
  public func increment(by difference: Value, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    update(wrappedValue + difference, FieldValue.increment(difference), option: option, completion: completion)
  }
}

extension Field where Value == Int {
  
  public func increment(by difference: Value, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    update(wrappedValue + difference, FieldValue.increment(Double(difference)), option: option, completion: completion)
  }
}

extension Field where Value == Float {
  
  public func increment(by difference: Value, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    update(wrappedValue + difference, FieldValue.increment(Double(difference)), option: option, completion: completion)
  }
}

extension Field {
  
  private func update(_ value: Value, _ fieldValue: Any, option: WriteOption = .default, completion: @escaping (Firestore.Error?) -> Void) {
    guard let keyPath = keyPath else { completion(.noKey); return }
    guard let document = parent?.parent as? Document else { completion(.unknown); return }
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
